module Api
  module V1
    module Users
      class PasswordsController < Devise::SessionsController
        respond_to :json

        def create
          self.resource = resource_class.send_reset_password_instructions(resource_params)
          yield resource if block_given?

          if successfully_sent?(resource)
            render json: { message: 'Email sent successfully!' }, status: :ok
          else
            render json: { error: resource.errors.full_messages.uniq.to_sentence&.humanize }, status: :unprocessable_entity
          end
        end

        def update
          self.resource = resource_class.reset_password_by_token(resource_params)
          yield resource if block_given?

          if resource.errors.empty?
            render json: { message: 'Password reset successfully!' }, status: :ok
          else
            set_minimum_password_length
            render json: { error: resource.errors.full_messages.uniq.to_sentence&.humanize }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
