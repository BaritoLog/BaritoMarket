module ChefHelper
  class KafkaRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(manifest, infrastructure_manifests, opts = {})
      @manifest = manifest
      @consul_hosts = generate_pf_meta("deployment_ip_addresses", {deployment_name: "#{manifest['cluster_name']}-consul"})
      
      @role_name = opts[:role_name] || 'kafka'
      @cluster_name = manifest['cluster_name']
      @hostname = manifest['name']
      kafka_template = DeploymentTemplate.find_by(name: 'kafka')
      @kafka_attrs = get_bootstrap_attributes(kafka_template.bootstrappers)
    end

    def generate
      return {} if @kafka_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @kafka_attrs["kafka"]["zookeeper"]["hosts"] = ["zookeeper.service.consul"]
      @kafka_attrs["kafka"]["kafka"]["hosts"] = ["kafka.service.consul"]
      @kafka_attrs["kafka"]["kafka"]["hosts_count"] = @manifest['count']
      @kafka_attrs["consul"]["hosts"] = @consul_hosts
      @kafka_attrs["run_list"] = ["role[#{@role_name}]"]

      if Figaro.env.datadog_integration == 'true'
        @kafka_attrs["datadog"]["datadog_api_key"] = Figaro.env.datadog_api_key
        @kafka_attrs["datadog"]["datadog_hostname"] = @hostname
        @kafka_attrs["datadog"]["kafka"]["instances"][0]["cluster_name"] = @cluster_name
        @kafka_attrs["run_list"] << 'recipe[datadog::default]'
        @kafka_attrs["run_list"] << 'recipe[datadog::kafka_datadog]'
      end

      @kafka_attrs
    end
  end
end
