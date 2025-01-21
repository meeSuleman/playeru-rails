module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        include ApiResponse
        include ErrorHandling
        respond_to :json

        rescue_from JWT::ExpiredSignature, with: :handle_expired_token

        def create
          user = User.find_by(email: params[:user][:email])
          if user_is_not_confirmed?(user)
            # Confirming user via OTP
            user.send_confirmation_instructions
            success_response('An OTP has been sent to your email. Please confirm your email before login.')
          else
            super
          end
        end

        private

        def handle_expired_token
          error_response('Your session has expired. Please log in again.', status: :unauthorized)
        end

        def user_is_not_confirmed?(user)
          user && user.valid_password?(params[:user][:password]) && !user.confirmed?
        end

        def respond_to_on_destroy
          if current_user
            success_response('Logged out successfully!')
          else
            error_response("Couldn't find an active session!", status: :unauthorized)
          end
        end

        def respond_with(resource, _opts = {})
          if resource.errors.blank?
            success_response(
              'Logged in successfully!',
              {
                user: user_data(resource),
                welcome_video_url: "#{Rails.application.credentials.dig(:aws, :cloudfront_domain)}/welcome-video/intro.mp4",
                token: request.env['warden-jwt_auth.token']
              }
            )
          else
            error_response(resource.errors.full_messages.uniq.to_sentence&.humanize)
          end
        end

        def user_data(user)
          profile_picture = user.profile_picture.attached? ? url_for(user.profile_picture) : nil
          user.as_json.merge(profile_picture_url: profile_picture)
        end
      end
    end
  end
end
