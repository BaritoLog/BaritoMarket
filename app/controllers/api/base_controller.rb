# DEPRECATION NOTICE
# This API and all of its inherited APIs will be deprecated in favor of v2
class Api::BaseController < ActionController::Base
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def build_errors(code, errors = [])
    { success: false, errors: errors, code: code }
  end

  private

  def user_not_authorized
    render json: "Unauthorized", status: :unauthorized
    return
  end
end
