class AddDetailsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :dob, :datetime
    add_column :users, :gender, :string
    add_column :users, :skill_level, :integer, default: 0, null: false
    add_column :users, :pickleball_rating, :float
  end
end
