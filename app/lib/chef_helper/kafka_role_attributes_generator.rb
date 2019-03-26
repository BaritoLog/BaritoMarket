module ChefHelper
  class KafkaRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @zookeeper_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'zookeeper')
      @hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'kafka')
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @role_name = opts[:role_name] || 'kafka'
      @cluster_name = component.infrastructure.cluster_name
      @hostname = component.hostname
      @ipaddress = component.ipaddress
      kafka_property = ComponentTemplate.find_by(name: 'kafka')
      @kafka_attrs = kafka_property.component_attributes
    end

    def generate
      return {} if @kafka_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @kafka_attrs['kafka']['zookeeper']['hosts'] = @zookeeper_hosts
      @kafka_attrs['kafka']['kafka']['hosts'] = @hosts
      @kafka_attrs['consul']['hosts'] = @consul_hosts
      @kafka_attrs['consul']['config']['consul.json']['bind_addr'] = @ipaddress
      @kafka_attrs['run_list'] = ["role[#{@role_name}]"]

      if Figaro.env.datadog_integration == 'true'
        @kafka_attrs['datadog']['datadog_api_key'] = Figaro.env.datadog_api_key
        @kafka_attrs['datadog']['datadog_hostname'] = @hostname
        @kafka_attrs['datadog']['kafka']['instances'][0]['cluster_name'] = @cluster_name
        @kafka_attrs['run_list'] << 'recipe[datadog::default]'
        @kafka_attrs['run_list'] << 'recipe[datadog::kafka_datadog]'
      end

      @kafka_attrs
    end
  end
end
