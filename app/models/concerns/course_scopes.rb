# app/models/concerns/course_scopes.rb
module CourseScopes
  extend ActiveSupport::Concern

  included do
    # ---------------- Default Scope ----------------
    default_scope { order(sequence: :asc) }

    scope :for_user_with_status, lambda { |user_id, status|
      joins(modules: :user_modules)
        .where(user_modules: { user_id: user_id, status: status })
        .group('courses.id')
        .having('COUNT(user_modules.idπ) = ?', TrainingModule.where(course_id: :course_id).count)
    }

    # Pending courses for a user
    scope :pending_for_user, ->(user_id) { for_user_with_status(user_id, :pending) }

    # Completed courses for a user
    scope :completed_for_user, ->(user_id) { for_user_with_status(user_id, :completed) }

    # Current course for a user (returns one course)
    scope :current_for_user, lambda { |user_id|
      joins(modules: :user_modules)
        .where(user_modules: { user_id: user_id, status: :current })
        .distinct.first
    }
    
  end
end
