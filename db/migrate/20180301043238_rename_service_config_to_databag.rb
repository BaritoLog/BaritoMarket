class RenameServiceConfigToDatabag < ActiveRecord::Migration
  def change
    rename_table :service_configs, :databags
  end
end
