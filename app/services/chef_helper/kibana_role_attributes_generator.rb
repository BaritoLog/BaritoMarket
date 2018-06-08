module ChefHelper
  class KibanaRoleAttributesGenerator
    def initialize(elasticsearch_host, consul_hosts, opts = {})
      @elasticsearch_host = elasticsearch_host
      @elasticsearch_port = opts[:elasticsearch_port] || 9200
      @consul_hosts = consul_hosts
      @role_name = opts[:role_name] || 'kibana'
    end

    def generate
      elasticsearch_url = "http://#{@elasticsearch_host}:#{@elasticsearch_port}"

      {
        'kibana' => {
          'config' => {
            'elasticsearch.url' => elasticsearch_url
          }
        },
        'consul' => {
          'run_as_server' => false,
          'hosts' => @consul_hosts
        },
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
