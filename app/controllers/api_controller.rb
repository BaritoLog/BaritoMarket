class ApiController < ApplicationController
  before_action :authenticate_token, :get_app

  def authenticate_token
    required_keys = [:token]
    errors = {}
    if !validate_required_keys(required_keys)
      key_list = required_keys.join(',')
      errors = build_errors(422, ["Invalid Params: #{key_list} is a required parameter"])
    elsif !BaritoApp.secret_key_valid?(params[:token])
      errors = build_errors(401, ["Unauthorized: #{params[:token]} is not a valid App Token"])
    end
    render json: errors, status: errors[:code] unless errors.blank?
  end

  def get_app
    @app = BaritoApp.find_by_secret_key(params[:token])
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
end
