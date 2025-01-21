module Api
  module V1
    class UsersController < Api::BaseController
      before_action :authenticate_user!

      def update_profile
        current_user.update!(profile_params)
        success_response('Profile updated successfully!', 
          { 
            user: profile_info,
            welcome_video_url: "#{Rails.application.credentials.dig(:aws, :cloudfront_domain)}/welcome-video/intro.mp4"
          }
        )
      end

      def fetch_profile
        success_response('User profile fetched successfully!',
          { 
            profile_info: profile_info,
            welcome_video_url: "#{Rails.application.credentials.dig(:aws, :cloudfront_domain)}/welcome-video/intro.mp4"
          }
        )
      end

      def contact_support
        params = contact_support_params
        UserMailer.contact_support(current_user.email, params[:text], params[:subject], current_user.name).deliver_later
        success_response('Support email sent successfully!')
      end

      def add_cart
        return error_response('Please provide the cart id') unless params[:cart_id].present?

        StoreCartService.new(current_user, params[:cart_id]).add_cart
        success_response('Cart saved successfully')
      end

      def remove_cart
        StoreCartService.new(current_user).remove_cart
        success_response('Cart removed')
      end

      private

      def profile_params
        params.require(:user).permit(:first_name, :last_name, :dob, :gender, :phone, :skill_level, :pickleball_rating, :profile_picture)
      end

      def contact_support_params
        params.permit(:text, :subject)
      end

      def profile_info
        profile_info = current_user.as_json
        profile_info[:profile_picture_url] = url_for(current_user.profile_picture) if current_user.profile_picture.attached?
        profile_info
      end
    end
  end
end
