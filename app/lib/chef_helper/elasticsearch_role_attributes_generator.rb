module ChefHelper
  class ElasticsearchRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(manifest, infrastructure_manifests, opts = {})
      @consul_hosts = generate_pf_meta("deployment_ip_addresses", 
        {deployment_name: "#{manifest['deployment_cluster_name']}-consul"})

      @role_name = opts[:role_name] || 'elasticsearch'
      @cluster_name = manifest['cluster_name']
      @hostname = generate_pf_meta("container_hostname")
      @port = opts[:port] || 9200      
      if manifest['count'].to_i <= 1
        @index_number_of_replicas = 0
        @minimum_master_nodes = 1
      else
        @index_number_of_replicas = 1
        @minimum_master_nodes = (manifest['count'].to_i/2 + 1).floor
      end

      elastic_template = DeploymentTemplate.find_by(name: 'elasticsearch')
      @elastic_attrs = get_bootstrap_attributes(elastic_template.bootstrappers)
    end

    def generate
      return {} if @elastic_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @elastic_attrs["elasticsearch"]["cluster_name"] = @cluster_name
      @elastic_attrs["elasticsearch"]["index_number_of_replicas"] = @index_number_of_replicas
      @elastic_attrs["elasticsearch"]["member_hosts"] = ['elasticsearch.service.consul']
      @elastic_attrs["elasticsearch"]["minimum_master_nodes"] = @minimum_master_nodes
      @elastic_attrs["consul"]["hosts"] = @consul_hosts
      @elastic_attrs["run_list"] = ["role[#{@role_name}]", 'recipe[elasticsearch_wrapper_cookbook::elasticsearch_set_replica]']

      if Figaro.env.datadog_integration == 'true'
        @elastic_attrs["datadog"]["datadog_api_key"] = Figaro.env.datadog_api_key
        @elastic_attrs["datadog"]["datadog_hostname"] = @hostname
        @elastic_attrs["datadog"]["elastic"]["instances"][0]["url"] = "http://127.0.0.1:#{@port}"
        @elastic_attrs["run_list"] << 'recipe[datadog::default]'
        @elastic_attrs["run_list"] << 'recipe[datadog::elastic_datadog]'
      end

      @elastic_attrs
    end
  end
end
