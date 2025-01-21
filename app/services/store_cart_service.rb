# app/services/store_cart_service.rb
class StoreCartService
  attr_reader :cart_id

  def initialize(user, cart_id=nil)
    @user = user
    @cart_id = cart_id
  end

  def add_cart
    @user.update!(active_cart_id: @cart_id)
  end

  def remove_cart
    @user.update!(active_cart_id: nil)
  end
  
end
