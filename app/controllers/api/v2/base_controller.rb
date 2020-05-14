class Api::V2::BaseController < ActionController::Base
  include Pundit

  before_action :authenticate!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def build_errors(code, errors = [])
    { success: false, errors: errors, code: code }
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
