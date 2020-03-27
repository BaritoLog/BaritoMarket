class AddManifestsToInfrastructures < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructures, :manifests, :jsonb, default: {}, null: false

    reversible do |direction|
      direction.up do
        Infrastructure.connection.schema_cache.clear!
        Infrastructure.reset_column_information

        Infrastructure.all.each do |infrastructure|
          next if [
            Infrastructure.provisioning_statuses[:deleted],
            Infrastructure.provisioning_statuses[:delete_error]
          ].include? infrastructure.provisioning_status

          manifests = Hash.new

          infrastructure.infrastructure_components.map do |component|
            type = component.component_type
            is_stateful = ["zookeeper", "kafka", "elasticsearch"].include? type

            if manifests.key?(type)
              manifests[type][:desired_num_replicas] += 1
              manifests[type][:min_available_replicas] += 1
            else
              cluster_name = infrastructure.cluster_name
              manifests[type] = {
                name: "#{cluster_name}-#{type}",
                cluster_name: Figaro.env.pathfinder_cluster,
                desired_num_replicas: 1,
                min_available_replicas: 0,
                type: type,
                definition: {
                  source: component.source,
                  bootstrappers: component.bootstrappers.map do |bootstrapper|
                    if bootstrapper["bootstrap_type"] == "chef-solo"
                      bootstrapper["bootstrap_attributes"]["consul"]["hosts"] = build_pf_meta(
                        "deployment_ip_addresses", deployment_name: "#{cluster_name}-consul"
                      )

                      if type == "zookeeper"
                        bootstrapper["bootstrap_attributes"]["zookeeper"]["my_id"] = build_pf_meta(
                          "container_id"
                        )
                        bootstrapper["bootstrap_attributes"]["zookeeper"]["hosts"] = build_pf_meta(
                          "deployment_host_sequences", host: "zookeeper.service.consul"
                        )
                      end
                    end

                    bootstrapper
                  end,
                  container_type: is_stateful ? "stateful" : "stateless",
                  allow_failure: !is_stateful
                }
              }
            end
          end

          infrastructure.update!(
            manifests: manifests.map { |k, v| v }
          )
        end
      end
    end
  end

  private
  def build_pf_meta(method_name, **kwargs)
    uri = URI(method_name)
    uri.query = URI.encode_www_form(kwargs) unless kwargs.empty?

    "$pf-meta:#{uri.to_s}"
  end
end
