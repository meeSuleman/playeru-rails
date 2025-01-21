class AddColumnsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :reset_otp, :string
    add_column :users, :reset_otp_sent_at, :datetime
    add_column :users, :is_onboarded, :boolean
    add_column :users, :phone, :string
  end
end
