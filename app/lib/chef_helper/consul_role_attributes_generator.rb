module ChefHelper
  class ConsulRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(manifest, infrastructure_manifests, opts = {})
      @hosts = fetch_hosts_address_manifest_by(manifest,'consul')
      @role_name = opts[:role_name] || 'consul'
      consul_template = ComponentTemplate.find_by(name: 'consul')
      @consul_attrs = get_bootstrap_attributes(consul_template.bootstrappers)
    end

    def generate
      return {} if @consul_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @consul_attrs["consul"]["hosts"] = @hosts
      @consul_attrs["run_list"] = ["role[#{@role_name}]"]
      @consul_attrs
    end
  end
end
