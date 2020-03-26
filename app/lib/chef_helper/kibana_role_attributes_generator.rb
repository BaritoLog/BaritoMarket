module ChefHelper
  class KibanaRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(manifest, infrastructure_manifests, opts = {})
      @consul_hosts = generate_pf_meta("deployment_ip_addresses", 
        {deployment_name: "#{manifest['deployment_cluster_name']}-consul"})
      @role_name = opts[:role_name] || 'kibana'
      @base_path = manifest['deployment_cluster_name']
      kibana_template = DeploymentTemplate.find_by(name: 'kibana')
      @kibana_attrs = get_bootstrap_attributes(kibana_template.bootstrappers)
    end

    def generate
      return {} if @kibana_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @kibana_attrs["kibana"]["config"]["server.basePath"] = "/#{@base_path}"
      @kibana_attrs["consul"]["hosts"] = @consul_hosts
      @kibana_attrs["run_list"] = ["role[#{@role_name}]"]

      @kibana_attrs
    end
  end
end
