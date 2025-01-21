module Api
  module V1
    class DashboardsController < Api::BaseController
      include TrainingModuleMapper

      before_action :authenticate_user!

      def index
        user = current_user
        sections = Section.includes(training_modules: :users_training_modules)
        total_progress = 0
        total_sections = sections.count

        courses_data = sections.map do |section|
          total_progress += calculate_total_section_progress(user, section) 
          user_modules = map_training_modules(section.training_modules, user)
    
          {
            id: section.id,
            overview_text: section.overview_text,
            overview_video: "#{Rails.application.credentials.dig(:aws, :cloudfront_domain)}/welcome-video/intro.mp4",
            level: section.name,
            completion_percentage: calculate_completion_percentage(user, section),
            course_status: calculate_section_status(user, section),
            training_modules: user_modules
          }
        end

        dashboard_info = {
          last_30_day_rating: user.pickleball_rating_change_last_30_days,
          playeru_rating: user.pickleball_rating.to_i,
          courses_progress: (total_progress / total_sections).round(2)
        }
    
        success_response('Dashboard info fetched successfully', { dashboard_info: dashboard_info, courses_info: courses_data })
      end
    
      private
    
      def calculate_completion_percentage(user, section)
        total_modules = section.training_modules.count
        completed_modules = section.training_modules.joins(:users_training_modules)
                                                    .where(users_training_modules: { user: user, status: 'completed' })
                                                    .count
        return 0 if total_modules.zero?
    
        (completed_modules.to_f / total_modules * 100).round(2)
      end

      def calculate_total_section_progress(user, section)
        training_modules = section.training_modules
        user_training_modules = user.users_training_modules.where(training_module_id: training_modules.pluck(:id))
    
        total_modules = training_modules.count
        completed_modules = user_training_modules.where(status: 'completed').count
    
        course_progress = if completed_modules == total_modules
                            100
                          elsif user_training_modules.exists?(status: 'current')
                            (completed_modules.to_f / total_modules * 100).round(2) # Partially completed
                          else
                            0
                          end
    
        course_progress
      end
    end
  end
end
