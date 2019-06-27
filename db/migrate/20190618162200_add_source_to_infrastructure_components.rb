class AddSourceToInfrastructureComponents < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructure_components, :source, :jsonb
    rename_column :infrastructure_components, :bootstrap_attributes, :bootstrappers
  end
end
