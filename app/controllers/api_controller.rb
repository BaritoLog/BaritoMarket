class ApiController < ApplicationController
  before_action :authenticate_token, :get_app

  def authenticate_token
    unless BaritoApp.secret_key_valid?(params[:token])
      body = {
        success: false,
        errors: ["Unauthorized: #{params[:token]} is not a valid App Token"],
      }
      render json: body, status: :unauthorized
    end
  end

  def get_app
    @app = BaritoApp.find_by_secret_key(params[:token])
  end
end
