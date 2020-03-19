class AddManifestsToClusterTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :cluster_templates, :manifests, :jsonb, default: {}, null: false

    reversible do |direction|
      direction.up do
        ClusterTemplate.connection.schema_cache.clear!
        ClusterTemplate.reset_column_information
        ClusterTemplate.all.each do |cluster_template|
          template_mainfests = cluster_template.instances.map { |instance|
              if instance["count"] == 0
                next
              end

              component_template = ComponentTemplate.find_by(name: instance["type"])
              is_stateful = ["zookeeper", "kafka", "elasticsearch"].include? instance["type"]
              
              {
                type: instance["type"],
                desired_num_replicas: instance["count"],
                min_available_replicas: instance["count"] - 1,
                definition: {
                  source: component_template.source,
                  bootstrappers: component_template.bootstrappers,
                  container_type: is_stateful ? "stateful" : "stateless",
                  allow_failure: !is_stateful
                }
              }
            }.compact

          cluster_template.update!(
            manifests: template_mainfests
          ) if template_mainfests.any?
        end
      end
    end
  end
end
