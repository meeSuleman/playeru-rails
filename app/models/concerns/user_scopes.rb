# app/models/concerns/user_scopes.rb
module UserScopes
  extend ActiveSupport::Concern

  included do
    # returns training modules against a course for a specific user
    scope :training_modules_for_course, ->(course_id) { training_modules.where(course_id: course_id) }
  end
end
