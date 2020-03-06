module ChefHelper
  class BaritoFlowProducerRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(manifest, infrastructure_manifests, opts = {})
      @consul_hosts = fetch_hosts_address_manifests_by(
        infrastructure_manifests, 'consul')
      barito_flow_producer_manifest = manifest[:definition][:bootstrappers][0][:bootstrap_attributes][:'barito-flow'][:producer]
      @max_tps = barito_flow_producer_manifest[:env_vars][:BARITO_PRODUCER_MAX_TPS] || 10
      @role_name = opts[:role_name] || 'barito-flow-producer'
      @producer_attrs = get_bootstrap_attributes(manifest[:definition][:bootstrappers])
    end

    def generate
      return {} if @producer_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @producer_attrs[:"barito-flow"][:producer][:env_vars][:BARITO_PRODUCER_MAX_TPS] = @max_tps

      @producer_attrs[:consul][:hosts] = @consul_hosts
      @producer_attrs[:run_list] = ["role[#{@role_name}]"]

      @producer_attrs
    end
  end
end
