module ChefHelper
  class KibanaRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @elasticsearch_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'elasticsearch')
      @elasticsearch_port = opts[:elasticsearch_port] || 9200
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @role_name = opts[:role_name] || 'kibana'
      @base_path = component.infrastructure.cluster_name
      @ipaddress = component.ipaddress
    end

    def generate
      elasticsearch_url = "http://#{@elasticsearch_hosts.first}:#{@elasticsearch_port}"

      {
        'kibana' => {
          'version' => '6.3.0',
          'config' => {
            'elasticsearch.url' => elasticsearch_url,
            'server.basePath' => "/#{@base_path}"
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
    end
  end
end
