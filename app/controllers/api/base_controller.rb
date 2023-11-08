# DEPRECATION NOTICE
# This API and all of its inherited APIs will be deprecated in favor of v2
class Api::BaseController < ActionController::Base
  include Pundit
  include Traceable

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  around_action :traced
  around_action :with_audit_logger

  def build_errors(code, errors = [])
    { success: false, errors: errors, code: code }
  end

  def trace_prefix
    'barito_market'
  end

  private

  def user_not_authorized
    render json: "Unauthorized", status: :unauthorized
    return
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

        unless @audit_payload.nil? or @audit_payload.empty?
          req_audit["data"] = @audit_payload
        end
        puts req_audit.to_json
      rescue
      end
    end
  end
end
