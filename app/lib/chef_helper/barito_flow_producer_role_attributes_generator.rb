module ChefHelper
  class BaritoFlowProducerRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(manifest, infrastructure_manifests, opts = {})
      @consul_hosts = generate_pf_meta("deployment_ip_addresses", 
        {deployment_name: "#{manifest['deployment_cluster_name']}-consul"})
      @role_name = opts[:role_name] || 'barito-flow-producer'
      producer_template = DeploymentTemplate.find_by(name: 'barito-flow-producer')
      @producer_attrs = get_bootstrap_attributes(producer_template.bootstrappers)
    end

    def generate
      return {} if @producer_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @producer_attrs["consul"]["hosts"] = @consul_hosts
      @producer_attrs["run_list"] = ["role[#{@role_name}]"]

      @producer_attrs
    end
  end
end
