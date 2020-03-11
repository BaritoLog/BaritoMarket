module ChefHelper
  class ZookeeperRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(manifest, infrastructure_manifests, opts = {})
      hosts = generate_pf_meta("deployment_ip_addresses", {deployment_name: "#{manifest['name']}"})
      @my_id = generate_pf_meta("container_id")

      @domains = generate_pf_meta("deployment_host_sequences", 
        {host: "zookeeper.service.consul"})

      @consul_hosts = generate_pf_meta("deployment_ip_addresses", {deployment_name: "#{manifest['deployment_cluster_name']}-consul"})
      @role_name = opts[:role_name] || :zookeeper
      @cluster_name = manifest['cluster_name']
      @hostname = manifest['name']
      zookeeper_template = DeploymentTemplate.find_by(name: 'zookeeper')
      @zookeeper_attrs = get_bootstrap_attributes(zookeeper_template.bootstrappers)
    end

    def generate
      return {} if @zookeeper_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @zookeeper_attrs["zookeeper"]["hosts"] = @domains
      @zookeeper_attrs["zookeeper"]["my_id"] = @my_id
      @zookeeper_attrs["consul"]["hosts"] = @consul_hosts
      @zookeeper_attrs["run_list"] = ["role[#{@role_name}]"]

      if Figaro.env.datadog_integration == :true
        @zookeeper_attrs["datadog"]["datadog_api_key"] = Figaro.env.datadog_api_key
        @zookeeper_attrs["datadog"]["datadog_hostname"] = @hostname
        @zookeeper_attrs["datadog"]["zk"]["instances"][0]["cluster_name"] = @cluster_name
        @zookeeper_attrs["run_list"] << 'recipe[datadog::default]'
        @zookeeper_attrs["run_list"] << 'recipe[datadog::zk_datadog]'
      end

      @zookeeper_attrs
    end
  end
end
