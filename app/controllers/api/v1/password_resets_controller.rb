module Api
  module V1
    class PasswordResetsController < Api::BaseController
      include UsersConcern

      before_action :find_resourse, only: [:generate_otp, :verify_otp]

      def generate_otp
          @user.save_reset_otp
          UserMailer.send_reset_otp(@user).deliver_now
          success_response('OTP for password reset sent successfully.')
      end

      # CURRENTLY WE ARE NOT USING THIS
      # def verify_otp
      #   if @user&.valid_otp?(params[:otp])
      #     confirm_user(@user) unless @user.confirmed?
      #     success_response('OTP verified successfully.', { verified_email: @user.email, otp: @user.reset_otp } )
      #   else
      #     error_response('Invalid or expired OTP.')
      #   end
      # end

      def reset_password
        @user = User.find_by(email: params[:email], reset_otp: params[:otp])
        if @user
          @user.confirm_it unless @user.confirmed?
          @user.reset_password(params[:password], params[:password_confirmation])
          success_response('Password updated successfully.')
        else
          error_response('Invalid OTP or you are not authorized to update password', status: :unauthorized)
        end
      end

      private

      def find_resourse
        @user = User.find_by!(email: params[:email])
      end
    end
  end
end
