module ChefHelper
  class ZookeeperRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(manifest, infrastructure_manifests, opts = {})
      hosts = fetch_hosts_address_manifest_by(manifest,'zookeeper')
      @my_id = (hosts.index("#{manifest[:name]}-01.node.zookeeper")) + 1

      @domains = []
      hosts.each_with_index do |host, idx|
        if idx+1 == @my_id
          @domains << "0.0.0.0"
        else
          @domains << "#{idx+1}.zookeeper.service.consul"
        end
      end
      
      @consul_hosts = fetch_hosts_address_manifests_by(infrastructure_manifests,'consul')
      @role_name = opts[:role_name] || :zookeeper
      @cluster_name = manifest[:cluster_name]
      @hostname = manifest[:name]
      @zookeeper_attrs = get_bootstrap_attributes(manifest[:definition][:bootstrappers])
    end

    def generate
      return {} if @zookeeper_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @zookeeper_attrs[:zookeeper][:hosts] = @domains
      @zookeeper_attrs[:zookeeper][:my_id] = @my_id
      @zookeeper_attrs[:consul][:hosts] = @consul_hosts
      @zookeeper_attrs[:run_list] = ["role[#{@role_name}]"]

      if Figaro.env.datadog_integration == :true
        @zookeeper_attrs[:datadog][:datadog_api_key] = Figaro.env.datadog_api_key
        @zookeeper_attrs[:datadog][:datadog_hostname] = @hostname
        @zookeeper_attrs[:datadog][:zk][:instances][0][:cluster_name] = @cluster_name
        @zookeeper_attrs[:run_list] << 'recipe[datadog::default]'
        @zookeeper_attrs[:run_list] << 'recipe[datadog::zk_datadog]'
      end

      @zookeeper_attrs
    end
  end
end
