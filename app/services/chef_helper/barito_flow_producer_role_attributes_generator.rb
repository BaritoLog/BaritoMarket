module ChefHelper
  class BaritoFlowProducerRoleAttributesGenerator
    def initialize(consul_hosts, opts = {})
      @consul_hosts = consul_hosts
      @role_name = opts[:role_name] || 'barito-flow-producer'
    end

    def generate
      {
        'consul' => {
          'run_as_server' => false,
          'hosts' => @consul_hosts
        },
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
