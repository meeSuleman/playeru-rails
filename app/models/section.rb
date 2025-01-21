# app/models/section.rb
class Section < ApplicationRecord
  # ---------------- Associations ----------------
  has_many :training_modules, dependent: :destroy
  has_many :users_training_modules, through: :training_modules

  has_one_attached :section_video

    # ---------------- Default Scope ----------------
    default_scope { order(rating: :asc) }
end
