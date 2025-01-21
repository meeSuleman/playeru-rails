module Api
  module V1
    class CoursesController < Api::BaseController
      include TrainingModuleMapper

      before_action :authenticate_user!
      before_action :find_course

      def show
        course_modules = map_training_modules(@course.training_modules, current_user)
        success_response('Course modules fetched successfully', course_modules)
      end

      private

      def find_course
        @course = Course.find_by!(id: params[:id])
      end
    end
  end
end
