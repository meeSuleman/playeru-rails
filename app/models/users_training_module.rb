# app/models/users_training_module.rb
class UsersTrainingModule < ApplicationRecord

  # ---------------- Validations ----------------
  validate :validate_user_assessment_video_size

  # ---------------- Associations ----------------
  has_one_attached :user_assessment_video
  belongs_to :user
  belongs_to :training_module

  enum :status, { current: 0, pending: 1, completed: 2 }
  enum :analysis_status, { not_sent: 0, waiting: 1, failed: 2, passed: 3 }

  # ---------------- Instance methods ----------------

  def attach_assessment(assessment)
    ActiveRecord::Base.transaction do
      # Purge the old video
      user_assessment_video.purge if user_assessment_video.attached?
  
      # Attach the new video
      blob = ActiveStorage::Blob.create_and_upload!(
        io: assessment,
        filename: assessment.original_filename,
        content_type: assessment.content_type,
        key: "user_assessment_videos/#{SecureRandom.uuid}/#{assessment.original_filename}"
      )
  
      self.user_assessment_video.attach(blob)
      save!
    rescue => e
      Rails.logger.error("Failed to attach assessment video: #{e.message}")
      errors.add(:user_assessment_video, 'could not be uploaded. Please try again.')
      raise ActiveRecord::Rollback
    end
  end
  
  
  private

  def validate_user_assessment_video_size
    return unless user_assessment_video.attached?

    if user_assessment_video.blob.byte_size > 2.gigabytes
      errors.add(:user_assessment_video, 'size cannot exceed 2GB')
    end
  end
end
