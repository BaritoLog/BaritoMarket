class ApplicationController < ActionController::Base
  include Pundit

  @audit_payload = {}

  before_action :authenticate_user!
  around_action :with_audit_logger

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action'
    redirect_to root_path
  end

  def audit_log (event_name, payload = {})
    if @audit_payload.nil?
      @audit_payload = {}
    end
    @audit_payload[event_name] = payload
  end

  def with_audit_logger
    begin
      yield
    ensure
      if controller_path == "health_checks"
        return
      end

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
          "user" => current_user ? current_user.username : "",
          "status" => response.status,
          "remote_ip" => request.remote_ip,
          "referer" => request.referer ? request.referer : "",
        }

        unless @app.nil?
          req_audit["app"] = @app.name
        end

        unless @app_group.nil?
          req_audit["app_group"] = @app_group.cluster_name
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
