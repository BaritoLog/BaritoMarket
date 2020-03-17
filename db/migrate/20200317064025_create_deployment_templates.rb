class CreateDeploymentTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :deployment_templates do |t|
      t.string :name
      t.jsonb :bootstrappers
      t.jsonb :source
    end

    add_index :deployment_templates, :name, unique: true

    reversible do |direction|
      direction.up do
        ComponentTemplate.all.each do |component_template|
          DeploymentTemplate.create!(
            name: component_template.name,
            bootstrappers: component_template.bootstrappers,
            source: component_template.source,
          )
        end
      end
    end
  end
end
