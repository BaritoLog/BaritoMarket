class Api::BaseController < ActionController::Base
  include Pundit

  before_action :authenticate_token

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authenticate_token
    required_keys = [:token]
    errors = {}
    if !validate_required_keys(required_keys)
      key_list = required_keys.join(',')
      errors = build_errors(422, ["Invalid Params: #{key_list} is a required parameter"])
    else
      @app = BaritoApp.find_by_secret_key(params[:token])
      if !@app.present?
        errors = build_errors(401, ["Unauthorized: #{params[:token]} is not a valid App Token"])
      end
    end
    render json: errors, status: errors[:code] unless errors.blank?
  end

  def build_errors(code, errors = [])
    { sucess: false, errors: errors, code: code }
  end

  def validate_required_keys(required_keys = {})
    valid = true
    required_keys.each do |key|
      valid = params.key?(key.to_sym) && !params[key.to_sym].blank?
    end
    valid
  end

  private

  def user_not_authorized
    render json: "Unauthorized", status: :unauthorized
    return
  end
end
