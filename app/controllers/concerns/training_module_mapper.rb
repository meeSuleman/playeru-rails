module TrainingModuleMapper
  extend ActiveSupport::Concern

  def serialize_training_module(module_instance, user)
    user_training_module = user.training_module_of_it(module_instance)
    {
      id: module_instance.id,
      name: module_instance.name,
      module_no: module_instance.sequence,
      course_name: module_instance.course.title,
      section_name: module_instance.section.name,
      status: user_training_module&.status || 'pending',
      is_favorite: user_training_module&.is_favorite || false,
      analysis_status: user_training_module&.analysis_status,
      description: ModuleDescriptionService.new(module_instance.name).fetch_description,
      video_duration: module_instance.duration,
      training_video_url: module_instance.cloudfront_url.to_s
    }
  end

  def map_training_modules(modules, user)
    modules.map { |module_instance| serialize_training_module(module_instance, user) }
  end

  def calculate_section_status(user, section)
    user_training_modules = user.users_training_modules.joins(:training_module).where(training_modules: { section_id: section.id })
  
    if user_training_modules.all? { |utm| utm.status == 'completed' }
      'completed'
    elsif user_training_modules.any? { |utm| utm.status == 'current' }
      'current'
    else
      'pending'
    end
  end
end