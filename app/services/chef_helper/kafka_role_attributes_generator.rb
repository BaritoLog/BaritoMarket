module ChefHelper
  class KafkaRoleAttributesGenerator
    def initialize(zookeeper_hosts, hosts, opts = {})
      @zookeeper_hosts = zookeeper_hosts
      @hosts = hosts
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
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
