module ChefHelper
  class ConsulRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
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
