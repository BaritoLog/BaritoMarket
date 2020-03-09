module ChefHelper
  class ElasticsearchRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(manifest, infrastructure_manifests, opts = {})
      hosts = fetch_hosts_address_manifest_by(
        manifest, 'elasticsearch')
      @consul_hosts = fetch_hosts_address_manifests_by(
        infrastructure_manifests, 'consul')
      @role_name = opts[:role_name] || 'elasticsearch'
      @cluster_name = manifest[:cluster_name]
      @hostname = manifest[:name]
      @port = opts[:port] || 9200
      elastic_bootstrap = manifest[:definition][:bootstrappers][0][:bootstrap_attributes][:elasticsearch]
      @index_number_of_replicas = elastic_bootstrap[:index_number_of_replicas]
      @minimum_master_nodes = elastic_bootstrap[:minimum_master_nodes]
      @elastic_attrs = get_bootstrap_attributes(manifest[:definition][:bootstrappers])
    end

    def generate
      return {} if @elastic_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @elastic_attrs[:elasticsearch][:cluster_name] = @cluster_name
      @elastic_attrs[:elasticsearch][:index_number_of_replicas] = @index_number_of_replicas
      @elastic_attrs[:elasticsearch][:member_hosts] = ['elasticsearch.service.consul']
      @elastic_attrs[:elasticsearch][:minimum_master_nodes] = @minimum_master_nodes
      @elastic_attrs[:consul][:hosts] = @consul_hosts
      @elastic_attrs[:run_list] = ["role[#{@role_name}]", 'recipe[elasticsearch_wrapper_cookbook::elasticsearch_set_replica]']

      if Figaro.env.datadog_integration == 'true'
        @elastic_attrs[:datadog][:datadog_api_key] = Figaro.env.datadog_api_key
        @elastic_attrs[:datadog][:datadog_hostname] = @hostname
        @elastic_attrs[:datadog][:elastic][:instances][0][:url] = "http://127.0.0.1:#{@port}"
        @elastic_attrs[:run_list] << 'recipe[datadog::default]'
        @elastic_attrs[:run_list] << 'recipe[datadog::elastic_datadog]'
      end

      @elastic_attrs
    end
  end
end
