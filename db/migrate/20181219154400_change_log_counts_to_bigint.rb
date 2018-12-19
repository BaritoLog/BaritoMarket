class ChangeLogCountsToBigint < ActiveRecord::Migration[5.2]
  def change
    change_column :barito_apps, :log_count, :bigint, default: 0
    change_column :app_groups, :log_count, :bigint, default: 0
  end
end
