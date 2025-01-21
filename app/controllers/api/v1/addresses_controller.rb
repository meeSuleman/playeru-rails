module Api
  module V1
    class AddressesController < Api::BaseController
      before_action :authenticate_user!

      def create
        address = current_user.addresses.new(address_params)
        address.save!
        success_response('Address saved successfully.')
      end

      def index
        success_response('Latest address fetched successfully', { last_saved_address: current_user.addresses.last })
      end

      private

      def address_params
        params.require(:address).permit(
          :address_1, :address_2, :city, :state_or_province,
          :state_or_province_code, :country_code, :postal_code, :phone
        )
      end
    end
  end
end
