class Api::V2::BaseController < ActionController::Base
  include Pundit
  include Traceable

  around_action :with_audit_logger
  before_action :authenticate!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  around_action :traced

  def build_errors(code, errors = [])
    { success: false, errors: errors, code: code }
  end

  def trace_prefix
    'barito_market'
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

  def validate_required_keys(required_keys = [])
    valid = false
    error_response = {}

    required_keys.each do |key|
      valid = params.key?(key.to_sym) && !params[key.to_sym].blank?
      unless valid
        error_response = build_errors(422,
        ["Invalid Params: #{key} is a required parameter"])
        break
      end
    end

    [valid, error_response]
  end

  def with_audit_logger
    begin
      yield
    ensure
      begin
        req_audit = {
          "type" => "audit",
          "timestamp" => Time.now.utc.iso8601,
          "pod_name" => Socket.gethostname,
          "controller" => controller_path,
          "action" => action_name,
          "request_host" => request.host,
          "request_method" => request.method,
          "request_path" => request.path,
          "access_token" => params[:access_token] ? params[:access_token][0,4] + "*****" : "",
          "status" => response.status,
          "remote_ip" => request.remote_ip,
          "user_agent" => request.user_agent ? request.user_agent : "",
        }

        unless @app.nil?
          req_audit["app"] = @app.name
        end

        unless @app_group.nil? or @app_group.helm_infrastructure.nil?
          req_audit["app_group"] = @app_group.helm_infrastructure.cluster_name
        end

        unless @audit_payload.nil? or @audit_payload.empty?
          req_audit["data"] = @audit_payload
        end
        puts req_audit.to_json
      rescue
      end
    end
  end
end
