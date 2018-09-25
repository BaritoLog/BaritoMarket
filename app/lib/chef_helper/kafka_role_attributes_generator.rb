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
    end

    def generate
      attrs = {
        'kafka' => {
          'zookeeper' => {
            'hosts' => @zookeeper_hosts
          },
          'kafka' => {
            'hosts' => @hosts
          }
        },
        'consul' => {
          'run_as_server' => false,
          'hosts' => @consul_hosts,
          'config' => {
            'consul.json' => {
              'bind_addr' => @ipaddress
            }
          }
        },
        'run_list' => ["role[#{@role_name}]"]
      }

      if Figaro.env.datadog_integration == 'true'
        attrs['datadog'] = {
          'datadog_api_key': Figaro.env.datadog_api_key,
          'datadog_hostname': @hostname,
          'kafka': {
            'instances': [
              {
                'host': 'localhost',
                'port': 8090,
                'cluster_name': "#{@cluster_name}",
                'tags': []
              }
            ]
          }
        }
        attrs['run_list'] << 'recipe[datadog::default]'
        attrs['run_list'] << 'recipe[datadog::kafka_datadog]'
      end

      return attrs
    end
  end
end
