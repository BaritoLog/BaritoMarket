class AddDisableAppTpsToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :disable_app_tps, :boolean, default: false
  end
end
