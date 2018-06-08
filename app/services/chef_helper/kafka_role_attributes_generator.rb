module ChefHelper
  class KafkaRoleAttributesGenerator
    def initialize(zookeeper_hosts, hosts, consul_hosts, opts = {})
      @zookeeper_hosts = zookeeper_hosts
      @hosts = hosts
      @consul_hosts = consul_hosts
      @role_name = opts[:role_name] || 'kafka'
    end

    def generate
      {
        'kafka' => {
          'zookeeper' => {
            'hosts' => @zookeeper_hosts
          },
          'kafka' => {
            'hosts' => @hosts
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
