# DEPRECATION NOTICE
# This API and all of its inherited APIs will be deprecated in favor of v2
class Api::BaseController < ActionController::Base
  include Pundit
  include Traceable

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  around_action :traced

  def build_errors(code, errors = [])
    { success: false, errors: errors, code: code }
  end

  def trace_prefix
    'barito_market'
  end

  private

  def user_not_authorized
    render json: "Unauthorized", status: :unauthorized
    return
  end
end
