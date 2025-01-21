class AddActiveCartIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :active_cart_id, :string
  end
end
