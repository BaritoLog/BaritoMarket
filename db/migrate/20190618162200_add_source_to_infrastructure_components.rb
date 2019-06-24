class AddSourceToInfrastructureComponents < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructure_components, :source_type, :string
    add_column :infrastructure_components, :mode, :string
    add_column :infrastructure_components, :remote, :string
    add_column :infrastructure_components, :fingerprint, :string
    add_column :infrastructure_components, :bootstrap_type, :string
    add_column :infrastructure_components, :bootstrap_cookbooks_url, :string
    rename_column :infrastructure_components, :image, :alias
  end
end
