class AddManifestsToClusterTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :cluster_templates, :manifests, :jsonb, default: {}, null: false

    reversible do |direction|
      direction.up do
        ClusterTemplate.all.each do |cluster_template|
          cluster_template.update!(
            manifests: cluster_template.instances.map do |instance|
              component_template = ComponentTemplate.find_by(name: instance["type"])
              is_stateful = instance["type"].include? ["zookeeper", "kafka", "elasticsearch"]

              {
                type: instance["type"],
                desired_num_replicas: instance["count"],
                min_available_count: instance["count"] - 1,
                definition: {
                  source: component_template.source,
                  bootstrappers: component_template.bootstrappers,
                  container_type: is_stateful ? "stateful" : "stateless",
                  allow_failure: !is_stateful
                }
              }
            end
          )
        end
      end
    end
  end
end
