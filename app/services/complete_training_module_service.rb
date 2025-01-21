# app/services/complete_training_module_service.rb
class CompleteTrainingModuleService
  attr_reader :response_data, :error_message

  def initialize(user, training_module)
    @user = user
    @training_module = training_module
    @response_data = {}
    @error_message = nil
  end

  def call
    users_training_module = @user.training_module_of_it(@training_module)

    unless users_training_module&.current?
      @error_message = users_training_module&.pending? ? 'You have not unlocked this module yet.' : 'You have already completed this module.'
      return false
    end

    ActiveRecord::Base.transaction do
      users_training_module.update!(status: 'completed', analysis_status: 'passed')
      handle_next_steps(users_training_module)
    end

    true
  end

  private

  def handle_next_steps(users_training_module)
    next_training_module = find_next_training_module()
    if next_training_module
      update_or_create_users_training_module(next_training_module, 'current')
      @response_data[:next_module_id] = next_training_module.id
    else
      handle_next_section()
      @user.increment_in_pb_rating
    end
  end

  def find_next_training_module
    @training_module.section.training_modules
                     .where('sequence > ?', @training_module.sequence)
                     .order(:sequence)
                     .first
  end

  def handle_next_section
    next_section = Section.where('rating > ?', @training_module.section.rating).order(:rating).first
    return unless next_section

    first_training_module = next_section.training_modules.order(:sequence).first
    return unless first_training_module

    update_or_create_users_training_module(first_training_module, 'current')
    @response_data[:next_module_id] = first_training_module.id
  end

  def update_or_create_users_training_module(training_module, status)
    UsersTrainingModule.find_or_create_by!(
      user: @user,
      training_module: training_module
    ).update!(status: status)
  end
end
