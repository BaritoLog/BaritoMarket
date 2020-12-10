# DEPRECATION NOTICE
# This API and all of its inherited APIs will be deprecated in favor of v2
class Api::BaseController < ActionController::Base
  include Pundit
  include Traceable

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  around_action :traced

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

  def determine_consul_host(infrastructure)
    consul_hosts = infrastructure.infrastructure_components.
      where(component_type: 'consul').
      pluck(:ipaddress).map { |ip| "#{ip}:#{Figaro.env.default_consul_port}" }
    consul_ipaddresses = infrastructure.fetch_manifest_ipaddresses('consul')
    consul_hosts = consul_ipaddresses.empty? ? consul_hosts : consul_ipaddresses
    consul_host = consul_ipaddresses.empty? ?  infrastructure.consul_host : consul_hosts.first
    return consul_hosts, consul_host
  end
end
