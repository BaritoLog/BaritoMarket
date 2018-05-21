class Api::BaseController < ApplicationController
  private

  def custom_render(json_string: , status:)
    self.status = status
    self.content_type = 'application/json'
    self.headers['Content-Length'] = json_string.present? ? json_string.bytesize.to_s : '0'.freeze
    self.response_body = json_string.present? ? json_string : ''.freeze
  end
end