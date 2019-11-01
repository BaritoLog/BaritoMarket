module ChefHelper
  class KibanaRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'component_type', 'consul')
      @role_name = opts[:role_name] || 'kibana'
      @base_path = component.infrastructure.cluster_name
      @ipaddress = component.ipaddress
      kibana_template = ComponentTemplate.find_by(name: 'kibana')
      @kibana_attrs = get_bootstrap_attributes(kibana_template.bootstrappers)
    end

    def generate
      return {} if @kibana_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @kibana_attrs['kibana']['config']['server.basePath'] = "/#{@base_path}"
      @kibana_attrs['consul']['hosts'] = @consul_hosts
      @kibana_attrs['consul']['config']['consul.json']['bind_addr'] = @ipaddress
      @kibana_attrs['run_list'] = ["role[#{@role_name}]"]

      @kibana_attrs
    end
  end
end
