module ErrorHandling
  extend ActiveSupport::Concern

  include ApiResponse

  # the later the definition of rescue handler, the higher the priority it has
  included do
    rescue_from StandardError, with: :render_internal_server_error_response
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
    rescue_from ActionController::ParameterMissing, with: :render_bad_request_response
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
  end

  private

  def render_not_found_response(exception)
    resource_name = exception.model || exception.message.match(/Couldn't find (\w+)/)&.captures&.first || "Resource"
    error_response("#{resource_name} does not exist", exception.message, status: :not_found)
  end

  def render_unprocessable_entity_response(exception)
    error_response('Unprocessable entity', exception.record.errors.full_messages, status: :unprocessable_entity)
  end

  def render_bad_request_response(exception)
    error_response('Bad request', exception.message, status: :bad_request)
  end

  def render_internal_server_error_response(exception)
    Rails.logger.error("#{exception.class} - #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))

    error_response('Internal server error', "#{exception.message} - Backtrace: #{exception.backtrace.join("\n")}",
                   status: :internal_server_error)
  end
end
