module Api
  class BaseController < ActionController::API
    include ActionController::MimeResponds
    include ApiResponse
    include ErrorHandling
  end
end
