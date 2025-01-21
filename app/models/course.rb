# app/models/course.rb
class Course < ApplicationRecord
  include CourseScopes

  # ---------------- Associations ----------------
  has_many :training_modules, dependent: :destroy
  has_many :users_training_modules, through: :training_modules
  has_many :users, through: :users_training_modules

end
