class AddClusterTemplateIdToInfrastructures < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructures, :cluster_template_id, :integer
    add_index :infrastructures, :cluster_template_id
    add_foreign_key :infrastructures, :cluster_templates, column: :cluster_template_id
  end
end
