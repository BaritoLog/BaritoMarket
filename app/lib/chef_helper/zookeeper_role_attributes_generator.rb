module ChefHelper
  class ZookeeperRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'zookeeper')
      @my_id = (@hosts.index(component.ipaddress) || @hosts.index(component.hostname)) + 1
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @role_name = opts[:role_name] || 'zookeeper'
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
          'datadog_hostname': @hostname
        }
        attrs['run_list'] << 'recipe[datadog::default]'
      end

      return attrs
    end
  end
end
