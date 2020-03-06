module ChefHelper
  class BaritoFlowConsumerRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(manifest, infrastructure_manifests, opts = {})
      @consul_hosts = fetch_hosts_address_manifests_by(
        infrastructure_manifests, 'consul')
      @role_name = opts[:role_name] || 'barito-flow-consumer'
      @consumer_attrs = get_bootstrap_attributes(manifest[:definition][:bootstrappers])
      @push_metric_url = "#{Figaro.env.market_end_point}/api/increase_log_count"
    end

    def generate
      return {} if @consumer_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @consumer_attrs[:"barito-flow"][:consumer][:env_vars][:BARITO_PUSH_METRIC_URL] = @push_metric_url

      @consumer_attrs[:consul][:hosts] = @consul_hosts
      @consumer_attrs[:consul][:run_as_server] = false
      @consumer_attrs[:run_list] = ["role[#{@role_name}]"]

      @consumer_attrs
    end
  end
end
