module ChefHelper
  class ZookeeperRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @hosts = fetch_hosts_address_by(
        infrastructure_components, 'component_type', 'zookeeper')
      @my_id = (@hosts.index(component.ipaddress) || @hosts.index(component.hostname)) + 1
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'component_type', 'consul')
      @role_name = opts[:role_name] || 'zookeeper'
      @cluster_name = component.infrastructure.cluster_name
      @hostname = component.hostname
      @ipaddress = component.ipaddress
      zookeeper_template = ComponentTemplate.find_by(name: 'zookeeper')
      @zookeeper_attrs = get_bootstrap_attributes(zookeeper_template.bootstrappers)
    end

    def generate
      return {} if @zookeeper_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @zookeeper_attrs['zookeeper']['hosts'] = @hosts
      @zookeeper_attrs['zookeeper']['my_id'] = @my_id
      @zookeeper_attrs['consul']['hosts'] = @consul_hosts
      @zookeeper_attrs['consul']['config']['consul.json']['bind_addr'] = @ipaddress
      @zookeeper_attrs['run_list'] = ["role[#{@role_name}]"]

      if Figaro.env.datadog_integration == 'true'
        @zookeeper_attrs['datadog']['datadog_api_key'] = Figaro.env.datadog_api_key
        @zookeeper_attrs['datadog']['datadog_hostname'] = @hostname
        @zookeeper_attrs['datadog']['zk']['instances'][0]['cluster_name'] = @cluster_name
        @zookeeper_attrs['run_list'] << 'recipe[datadog::default]'
        @zookeeper_attrs['run_list'] << 'recipe[datadog::zk_datadog]'
      end

      @zookeeper_attrs
    end
  end
end
