class AddBootstrapAttributeToInfrastructureComponents < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructure_components, :bootstrap_attribute, :jsonb, null: false, default: {}
  end
end
