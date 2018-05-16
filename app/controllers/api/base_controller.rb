class Api::BaseController < ApplicationController
  before_action :validate_application_secret

  HTTP_HEADER = "X-App-Secret"

  def validate_application_secret
    req_header = request.headers[HTTP_HEADER]
    @app = App.find_by_secret_key(req_header)
    if @app.nil? or req_header.blank?
      custom_render json_string: {:errors => "Invalid App Secret"}.to_json, status: :unauthorized
      return
    end
  end

  private

  def custom_render(json_string: , status:)
    self.status = status
    self.content_type = 'application/json'
    self.headers['Content-Length'] = json_string.present? ? json_string.bytesize.to_s : '0'.freeze
    self.response_body = json_string.present? ? json_string : ''.freeze
  end
end