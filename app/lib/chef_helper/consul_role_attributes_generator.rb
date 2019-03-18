module ChefHelper
  class ConsulRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @role_name = opts[:role_name] || 'consul'
      @ipaddress = component.ipaddress
      consul_property = ComponentProperty.find_by(name: 'consul')
      @consul_attrs = consul_property.component_attributes
    end

    def generate
      return {} if @consul_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @consul_attrs["consul"]["hosts"] = @hosts
      @consul_attrs["consul"]["config"]["consul.json"]["bind_addr"] = @ipaddress
      @consul_attrs["run_list"] = ["role[#{@role_name}]"]
      @consul_attrs
    end
  end
end
