module ChefHelper
  class ZookeeperRoleAttributesGenerator
    def initialize(host, hosts, opts = {})
      @hosts = hosts
      @my_id = hosts.index(host) + 1
      @role_name = opts[:role_name] || 'zookeeper'
    end

    def generate
      {
        'zookeeper' => {
          'hosts' => @hosts,
          'my_id' => @my_id
        },
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
