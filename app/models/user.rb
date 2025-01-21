class User < ApplicationRecord
  include UserScopes
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # ---------------- Validations ----------------
  validates :skill_level, inclusion: { in: 1..10 }, on: :update
  validates :first_name, :last_name, :dob, :gender, presence: true,  on: :update
  validates :pickleball_rating, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true, on: :update
  validate :profile_picture_size_validation
  validates :email, presence: true, uniqueness: true, format: {
    with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/,
    message: 'is not a valid email format'
  }

  # ---------------- Constants ----------------
  OTP_LENGTH = 6
  OTP_EXPIRY_TIME = 15.minutes

  # ---------------- Associations ----------------
  has_paper_trail
  has_one_attached :profile_picture
  has_many :users_training_modules, dependent: :destroy
  has_many :training_modules, through: :users_training_modules
  has_many :courses, through: :training_modules
  has_many :addresses, dependent: :destroy

  # ---------------- Callbacks ----------------
  after_create :initialize_sections
  before_update :update_onboarding_status, if: -> { !is_onboarded }

  # ---------------- Instance methods ----------------
  def name
    "#{first_name} #{last_name}"
  end

  def send_confirmation_instructions
    token = generate_otp
    self.confirmation_token = token
    self.confirmation_sent_at = Time.zone.now
    save!(validate: false)
    UserMailer.confirmation_instructions(self, self.confirmation_token).deliver_now
  end

  def save_reset_otp
    self.reset_otp = generate_otp
    self.reset_otp_sent_at = Time.zone.now
    save!(validate: false)
  end

  def valid_otp?(entered_otp)
    reset_otp.present? && reset_otp == entered_otp
  end

  def confirm_it
    self.confirm
    update_column(:confirmation_token, nil)
  end

  def reset_password(new_pass, confirm_pass)
    self.password = new_pass
    self.password_confirmation = confirm_pass
    self.reset_otp = nil
    self.reset_otp_sent_at = nil
    save!(validate: false)
  end

  def generate_otp
    SecureRandom.random_number(10**OTP_LENGTH).to_s.rjust(OTP_LENGTH, '0')
  end

  # Calculate pickleball_rating increase over the last 30 days
  def pickleball_rating_change_last_30_days
    version_30_days_ago = versions.where('created_at >= ?', 30.days.ago.utc).order(:created_at).first
    rating_30_days_ago = version_30_days_ago&.reify&.pickleball_rating.to_i
    pickleball_rating.to_i - rating_30_days_ago
  end

  def increment_in_pb_rating
    new_rating = pickleball_rating.to_i + 1
    update!(pickleball_rating: new_rating)
  end

  def onboarded?
    skill_level.present? &&
      first_name.present? &&
      last_name.present? &&
      phone.present? &&
      dob.present?
  end

  def training_module_of_it(training_module)
    users_training_modules.find_by!(training_module: training_module)
  end

  def latest_training_module
    pickleball_rating == 4 ? users_training_modules.completed.last&.training_module : users_training_modules.current.first&.training_module
  end

  private

  def profile_picture_size_validation
    if profile_picture.attached? && profile_picture.blob.byte_size > 10.megabytes
      errors.add(:profile_picture, "should be less than 10MB")
    end
  end

  def update_onboarding_status
    update_column(:is_onboarded, onboarded?)
  end

  def initialize_sections
    Section.find_each do |section|
      if section.rating == 2.5
        section.training_modules.each_with_index do |training_module, index|
          status = index.zero? ? 'current' : 'pending' # First module is current, others are pending
          UsersTrainingModule.create(user: self, training_module: training_module, status: status)
        end
      else
        section.training_modules.each do |training_module|
          UsersTrainingModule.create(user: self, training_module: training_module, status: 'pending')
        end
      end
    end
  end
end
