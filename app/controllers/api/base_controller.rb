class Api::BaseController < ApplicationController
  before_action :validate_application_secret

  HTTP_HEADER = "APPLICATION-SECRET"

  def validate_application_secret
    req_header = request.headers[HTTP_HEADER]
    unless req_header.blank?
      @client = Client.find_by_application_secret(req_header)
    else
      custom_render json_string: {:errors => "Invalid Application Secret"}.to_json, status: :unauthorized
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