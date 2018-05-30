module ChefHelper
  class KibanaRoleAttributesGenerator
    def initialize(elasticsearch_host, opts = {})
      @elasticsearch_host = elasticsearch_host
      @elasticsearch_port = opts[:elasticsearch_port] || 9200
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
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
