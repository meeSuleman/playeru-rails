class ApplicationController < ActionController::Base
  # include ErrorHandling  #TODO

  protect_from_forgery with: :null_session
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email password])
  end
end
