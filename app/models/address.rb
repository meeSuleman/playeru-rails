# app/models/address.rb
class Address < ApplicationRecord
  # ---------------- Associations ----------------
  belongs_to :user
  validates :address_1, :city, :state_or_province, :state_or_province_code, 
            :country_code, :postal_code, :phone, presence: true
end
