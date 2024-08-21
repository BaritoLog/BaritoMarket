class Api::V3::BaseController < ActionController::Base
  include Pundit
  include Traceable

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    render json: {
      success: false,
      errors: :unauthorized,
    }, status: :unauthorized
    return
  end
end
