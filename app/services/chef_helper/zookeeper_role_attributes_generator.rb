module ChefHelper
  class ZookeeperRoleAttributesGenerator
    def initialize(host, hosts, consul_hosts, opts = {})
      @hosts = hosts
      @my_id = hosts.index(host) + 1
      @consul_hosts = consul_hosts
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
