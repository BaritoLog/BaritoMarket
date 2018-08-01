module ChefHelper
  class ZookeeperRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'zookeeper')
      @my_id = hosts.index(host) + 1
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @role_name = opts[:role_name] || 'zookeeper'
    end

    def generate
      {
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
    end
  end
end
