class RenameInstancesToManifest < ActiveRecord::Migration[5.2]
  def change
    rename_column :infrastructures, :instances, :manifests
    rename_column :cluster_templates, :instances, :manifests
  end
end