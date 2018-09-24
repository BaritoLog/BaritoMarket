module ChefHelper
  class ElasticsearchRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @role_name = opts[:role_name] || 'elasticsearch'
      @hostname = component.hostname
    end

    def generate
      attrs = {
        'elasticsearch' => {
          'version' => '6.3.0',
          'allocated_memory' => 12000000,
          'max_allocated_memory' => 16000000
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
