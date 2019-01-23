class Api::V2::BaseController < ActionController::Base
  include Pundit

  before_action :authenticate!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def build_errors(code, errors = [])
    { success: false, errors: errors, code: code }
  end

  private

  def authenticate!
    unless ExtApp.valid_access_token? params[:access_token]
      render json: "Unauthorized", status: :unauthorized
      return
    end
  end

  def user_not_authorized
    render json: "Unauthorized", status: :unauthorized
    return
  end
end
