module ChefHelper
  class ElasticsearchRoleAttributesGenerator
    def initialize(consul_hosts, opts = {})
      @consul_hosts = consul_hosts
      @role_name = opts[:role_name] || 'elasticsearch'
    end

    def generate
      {
        'java' => {
          'jdk_version' => '8'
        },
        'elasticsearch' => {
          'version' => '5.6.9'
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
