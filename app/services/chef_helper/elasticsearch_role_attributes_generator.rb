module ChefHelper
  class ElasticsearchRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @role_name = opts[:role_name] || 'elasticsearch'
    end

    def generate
      {
        'java' => {
          "install_flavor" => "openjdk",
          'jdk_version' => '8'
        },
        'elasticsearch' => {
          'version' => '5.6.9',
          'allocated_memory' => 12000000,
          'max_allocated_memory' => 16000000
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
