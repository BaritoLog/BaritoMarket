class RenameConfigJsonColumnToData < ActiveRecord::Migration
  def change
    rename_column :databags, :config_json, :data
  end
end
