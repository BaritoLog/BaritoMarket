class Api::AppsController < Api::BaseController
  before_action :validate_application

  HTTP_HEADER = "X-App-Secret"
  HTTP_HEADER_CLUSTER_NAME = "X-App-Cluster-Name"

  def index
    render json: @app.as_json(only: [:id, :name, :consul]), status: :ok
  end

  private

  def validate_application
    req_header = nil

    if not request.headers[HTTP_HEADER].blank?
      req_header = request.headers[HTTP_HEADER]
      @app = App.find_by_secret_key(req_header)
    end

    if not request.headers[HTTP_HEADER_CLUSTER_NAME].blank?
      req_header = request.headers[HTTP_HEADER_CLUSTER_NAME]
      @app = App.find_by_cluster_name(req_header)
    end

    if @app.nil? or req_header.blank?
      custom_render json_string: {:errors => "Invalid App"}.to_json, status: :unauthorized
      return
    elsif @app.app_status.INACTIVE?
      custom_render json_string: {:errors => "App is inactive"}.to_json, status: :not_found
      return
    end
  end
end