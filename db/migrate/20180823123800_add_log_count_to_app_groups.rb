class AddLogCountToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :log_count, :integer, default: 0
  end
end
