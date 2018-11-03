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
    end

    def generate
      attrs = {
        'elasticsearch' => {
          'version' => '6.3.0',
          'allocated_memory' => 8000000,
          'max_allocated_memory' => 16000000,
          'cluster_name' => "#{@cluster_name}",
          'index_number_of_replicas' => @index_number_of_replicas
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
        'run_list' => ["role[#{@role_name}]", 'recipe[elasticsearch_wrapper_cookbook::elasticsearch_set_replica]']
      }

      if Figaro.env.datadog_integration == 'true'
        attrs['datadog'] = {
          'datadog_api_key': Figaro.env.datadog_api_key,
          'datadog_hostname': @hostname,
          'elastic': {
            'instances': [
              { 
                'url': "http://#{@ipaddress}:#{@port}",
                'tags': []
              }
            ]
          }
        }
        attrs['run_list'] << 'recipe[datadog::default]'
        attrs['run_list'] << 'recipe[datadog::elastic_datadog]'
      end

      return attrs
    end
  end
end
