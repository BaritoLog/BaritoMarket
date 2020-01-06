module ChefHelper
  class ConsulRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @role_name = opts[:role_name] || 'consul'
      @ipaddress = component.ipaddress
      consul_template = ComponentTemplate.find_by(name: 'consul')
      @consul_attrs = get_bootstrap_attributes(consul_template.bootstrappers)
    end

    def generate
      return {} if @consul_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @consul_attrs["consul"]["hosts"] = ['consul.service.consul']
      @consul_attrs["consul"]["config"]["consul.json"]["bind_addr"] = @ipaddress
      @consul_attrs["run_list"] = ["role[#{@role_name}]"]
      @consul_attrs
    end
  end
end
