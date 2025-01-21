module Api
  module V1
    class ConfirmationsController < Api::BaseController
      include UsersConcern

      before_action :find_resourse
      OTP_EXPIRATION_DURATION = 15.minutes

      def validate_otp
        if valid_otp?(@user)
          @user.confirm_it
          jwt_token = generate_auth_token(@user)
          success_response('Email confirmed successfully',
            { 
              token: jwt_token,
              welcome_video_url: "#{Rails.application.credentials.dig(:aws, :cloudfront_domain)}/welcome-video/intro.mp4"
            }
          )
        else
          error_response('Invalid or expired OTP. Please try again.', status: :unprocessable_entity)
        end
      end

      def resend_otp
        @user.send_confirmation_instructions
        success_response('A new OTP has been sent to your email.')
      end

      private

      def find_resourse
        @user = User.find_by!(email: permitted_params[:email])
      end

      def valid_otp?(user)
        user &&
          user.confirmation_token == permitted_params[:otp] &&
          user.confirmation_sent_at >= OTP_EXPIRATION_DURATION.ago
      end

      def permitted_params
        params.require(:user).permit(:otp, :email)
      end

      def generate_auth_token(user)
        Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
      end
    end
  end
end
