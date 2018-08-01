class AddBootstrapAttributesToInfrastructureComponents < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructure_components, :bootstrap_attributes, :jsonb, null: false, default: {}
  end
end
