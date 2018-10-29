class AddLogRetentionToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :log_retention_days, :integer, default: 30
  end
end
