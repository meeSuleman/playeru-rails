module Api
  module V1
    class SectionsController < Api::BaseController
      include TrainingModuleMapper

      before_action :authenticate_user!
      before_action :find_section, only: [:show]

      def skip_beginner
        beginner_modules = Section.find_by(rating: 2.5)&.training_modules
      
        ActiveRecord::Base.transaction do
          beginner_modules.each do |module_instance|
            service = CompleteTrainingModuleService.new(current_user, module_instance)
            unless service.call
              raise ActiveRecord::Rollback, "Failed to skip training module: #{module_instance.id}"
            end
          end
        end
      
        success_response('Beginner course skipped! You can now watch advanced beginner.')
      end

      def show
        section_modules = map_training_modules(@section.training_modules, current_user)
        success_response('Section modules successfully', section_modules)
      end

      private

      def find_section
        @section = Section.find_by!(id: params[:id])
      end
      
    end
  end
end
