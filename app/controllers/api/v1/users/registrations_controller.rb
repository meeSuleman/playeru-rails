module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        include ApiResponse
        include ErrorHandling
        respond_to :json

        def create
          existing_user = User.find_by(email: params[:email])

          if existing_user && !existing_user.confirmed?
            error_response('Email has already been taken. Please log in or use a different email.')
          else
            @success_message = 'OTP has been sent to your email!'
            super
          end
        end

        def update
          @success_message = 'Profile updated successfully!'
          super
        end

        protected

        def update_resource(resource, params)
          if params[:password].present? && resource.valid_password?(params[:password])
            resource.errors.add(:base, 'New password cannot be the same as your old password!')
          elsif params[:password].blank?
            resource.update_without_password(params)
          else
            resource.update_with_password(params)
          end
        end

        private

        def respond_with(resource, _opts = {})
          if resource.errors.blank?
            success_response(@success_message, resource)
          else
            error_response(resource.errors.full_messages.uniq.to_sentence&.humanize)
          end
        end
      end
    end
  end
end
