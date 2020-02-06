class AddLogRetentionDaysToBaritoApps < ActiveRecord::Migration[5.2]
  def change
    add_column :barito_apps, :log_retention_days, :integer
  end
end
