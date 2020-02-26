class RenameInstancesToManifest < ActiveRecord::Migration[5.2]
  def change
    rename_column :infrastructures, :instances, :manifest
    rename_column :cluster_templates, :instances, :manifest
  end
end