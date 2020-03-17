class AddManifestsToInfrastructures < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructures, :manifests, :jsonb, default: {}, null: false

    reversible do |direction|
      direction.up do
        Infrastructure.all.each do |infrastructure|
          manifests = Hash.new

          infrastructure.infrastructure_components.map do |component|
            type = component.component_type
            is_stateful = type.include? ["zookeeper", "kafka", "elasticsearch"]

            if manifests.has_key?(type)
              manifests[type]["count"] += 1
            else
              manifests[type] = {
                count: 1,
                type: type,
                definition: {
                  source: component.source,
                  bootstrappers: component.bootstrappers,
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
end
