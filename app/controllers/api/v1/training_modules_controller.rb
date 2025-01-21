# app/controllers/api/v1/training_modules_controller.rb
module Api
  module V1
    class TrainingModulesController < Api::BaseController
      include TrainingModuleMapper

      before_action :authenticate_user!
      before_action :set_training_module, only: [:completion, :save_assesment,:mark_favorite, :upload_assessment_video]

      def completion
        return save_assesment if params[:analysis] == 'failed'

        service = CompleteTrainingModuleService.new(current_user, @training_module)

        if service.call
          success_response('Training module marked as completed', service.response_data)
        else
          error_response(service.error_message)
        end
      end

      def save_assesment
        return error_response('Analysis cannot be blank') if params[:analysis].blank?
      
        users_training_module = current_user.training_module_of_it(@training_module)
        unless users_training_module&.current?
          err = users_training_module&.pending? ? 'You have not unlocked this module yet.' : 'You have already completed this module.'
          error_response(err)
        else
          users_training_module.update!(analysis_status: params[:analysis])
          success_response('Analysis saved')
        end
      end

      def upload_assessment_video
        return error_response('Please attach a video to upload') if params[:user_assessment_video].nil?
      
        users_training_module = current_user.training_module_of_it(@training_module)
        users_training_module.attach_assessment(params[:user_assessment_video])
        success_response('Video saved successfully', video_url: url_for(users_training_module.user_assessment_video))
      end
      

      def full_library
        latest_module = current_user.latest_training_module

        success_response('Library fetched successfully', {
          latest_video: serialize_training_module(latest_module, current_user),
          courses_data: prepare_sections_data + prepare_courses_data
        })
      end

      def mark_favorite
        user_module = current_user.training_module_of_it(@training_module)
        user_module.update!(is_favorite: params[:favorite] || false)
        res_message = params[:favorite] ? 'added to' : 'removed from'
        success_response("Video #{res_message} favorites")
      end

      def fetch_favorites
        fav_modules = current_user.training_modules.where(users_training_modules: { is_favorite: true })
        success_response('Courses modules successfully', { fav_modules: map_training_modules(fav_modules, current_user) })
      end

      private

      def set_training_module
        @training_module = TrainingModule.find_by!(id: params[:id])
      end

      def prepare_sections_data
        sections = Section.includes(:training_modules).all
        sections.map do |section|
          {
            id: section.id,
            overview_text: section.overview_text,
            title: "THE #{section.rating} CLUB",
            course_status: calculate_section_status(current_user, section),
            section_modules: map_training_modules(section.training_modules, current_user),
            overview_video: "#{Rails.application.credentials.dig(:aws, :cloudfront_domain)}/welcome-video/intro.mp4"
          }
        end
      end
      
      def prepare_courses_data
        courses = Course.includes(training_modules: [:section]).all
        courses.map do |course|
          {
            id: course.id,
            title: "#{course.title.upcase} BASICS",
            overview_text: "Pending from client side",
            overview_video: "#{Rails.application.credentials.dig(:aws, :cloudfront_domain)}/welcome-video/intro.mp4",
            course_modules: map_training_modules(course.training_modules, current_user),
          }
        end
      end
    end
  end
end
