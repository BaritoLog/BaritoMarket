module ChefHelper
  class ConsulRoleAttributesGenerator
    def initialize(hosts, opts = {})
      @hosts = hosts
      @role_name = opts[:role_name] || 'consul'
    end

    def generate
      {
        'consul' => {
          'hosts' => @hosts
        },
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
