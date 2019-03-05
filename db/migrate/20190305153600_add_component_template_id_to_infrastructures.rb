class AddComponentTemplateIdToInfrastructures < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructures, :component_template_id, :integer
    add_index :infrastructures, :component_template_id
    add_foreign_key :infrastructures, :component_templates, column: :component_template_id
  end
end
