module ChefHelper
  class BaritoFlowProducerRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'component_type', 'consul')
      @max_tps = component.infrastructure.options['max_tps'] || 10
      @role_name = opts[:role_name] || 'barito-flow-producer'
      @ipaddress = component.ipaddress
      producer_template = ComponentTemplate.find_by(name: 'barito-flow-producer')
      @producer_attrs = get_bootstrap_attributes(producer_template.bootstrappers)
    end

    def generate
      return {} if @producer_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @producer_attrs['barito-flow']['producer']['env_vars']['BARITO_CONSUL_URL'] = "http://#{@consul_hosts.sample}:#{Figaro.env.default_consul_port}"
      @producer_attrs['barito-flow']['producer']['env_vars']['BARITO_PRODUCER_MAX_TPS'] = @max_tps

      @producer_attrs['consul']['hosts'] = @consul_hosts
      @producer_attrs['consul']['config']['consul.json']['bind_addr'] = @ipaddress
      @producer_attrs['run_list'] = ["role[#{@role_name}]"]

      @producer_attrs
    end
  end
end
