module ChefHelper
  class ElasticsearchRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'elasticsearch')
      @role_name = opts[:role_name] || 'elasticsearch'
      @cluster_name = component.infrastructure.cluster_name
      @hostname = component.hostname
      @ipaddress = component.ipaddress
      @port = opts[:port] || 9200
      if @hosts.size <= 1
        @index_number_of_replicas = 0
      else
        @index_number_of_replicas = 1
      end
      elastic_property = ComponentProperty.find_by(name: 'elasticsearch')
      @elastic_attrs = elastic_property.component_attributes
    end

    def generate
      return {} if @elastic_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @elastic_attrs['elasticsearch']['version'] = '6.3.0'
      @elastic_attrs['elasticsearch']['allocated_memory'] = 12000000
      @elastic_attrs['elasticsearch']['max_allocated_memory'] = 16000000
      @elastic_attrs['elasticsearch']['cluster_name'] = @cluster_name
      @elastic_attrs['elasticsearch']['index_number_of_replicas'] = @index_number_of_replicas
      @elastic_attrs['consul']['hosts'] = @consul_hosts
      @elastic_attrs['consul']['run_as_server'] = false
      @elastic_attrs['consul']['config']['consul.json']['bind_addr'] = @ipaddress
      @elastic_attrs['run_list'] = ["role[#{@role_name}]", 'recipe[elasticsearch_wrapper_cookbook::elasticsearch_set_replica]']

      if Figaro.env.datadog_integration == 'true'
        @elastic_attrs['datadog']['datadog_api_key'] = Figaro.env.datadog_api_key
        @elastic_attrs['datadog']['datadog_hostname'] = @hostname
        @elastic_attrs['datadog']['elastic']['instances'][0]['url'] = "http://#{@ipaddress}:#{@port}"
        @elastic_attrs['run_list'] << 'recipe[datadog::default]'
        @elastic_attrs['run_list'] << 'recipe[datadog::elastic_datadog]'
      end

      @elastic_attrs
    end
  end
end
