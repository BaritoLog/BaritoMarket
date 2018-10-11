class Api::BaseController < ActionController::Base
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def build_errors(code, errors = [])
    { sucess: false, errors: errors, code: code }
  end

  private

  def user_not_authorized
    render json: "Unauthorized", status: :unauthorized
    return
  end
end
