class CreateDeploymentTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :deployment_templates do |t|
      t.string :name
      t.jsonb :bootstrappers
    end

    add_index :deployment_templates, :name, unique: true

    reversible do |direction|
      direction.up do
        ComponentTemplate.all.each do |component_template|
          DeploymentTemplate.create!(
            name: component_template.name,
            bootstrappers: component_template.bootstrappers,
          )
        end
      end
    end
  end
end
