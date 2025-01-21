# app/models/training_module.rb
class TrainingModule < ApplicationRecord
  # ---------------- Associations ----------------
  belongs_to :section
  belongs_to :course
  has_many :users_training_modules, dependent: :destroy
  has_many :users, through: :users_training_modules
  has_one_attached :training_video

  # ---------------- Default Scope ----------------
  default_scope { order(sequence: :asc) }
end
