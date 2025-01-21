class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state_or_province
      t.string :state_or_province_code
      t.string :country_code
      t.string :postal_code
      t.string :phone

      t.timestamps
    end
  end
end
