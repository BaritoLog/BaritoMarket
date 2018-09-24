module ChefHelper
  class ZookeeperRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'zookeeper')
      @my_id = (@hosts.index(component.ipaddress) || @hosts.index(component.hostname)) + 1
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @role_name = opts[:role_name] || 'zookeeper'
      @cluster_name = component.infrastructure.cluster_name
      @hostname = component.hostname
    end

    def generate
      attrs = {
        'zookeeper' => {
          'hosts' => @hosts,
          'my_id' => @my_id
        },
        'consul' => {
          'run_as_server' => false,
          'hosts' => @consul_hosts
        },
        'run_list' => ["role[#{@role_name}]"]
      }

      if Figaro.env.datadog_integration == 'true'
        attrs['datadog'] = {
          'datadog_api_key': Figaro.env.datadog_api_key,
          'datadog_hostname': @hostname,
          'zk': {
            'instances': [
              {
                'host': 'localhost',
                'port': 2181,
                'cluster_name': "#{@cluster_name}"
              }
            ]
          }
        }
        attrs['run_list'] << 'recipe[datadog::default]'
        attrs['run_list'] << 'recipe[datadog::zk_datadog]'
      end

      return attrs
    end
  end
end
