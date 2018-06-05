class AddLogCountToBaritoApps < ActiveRecord::Migration[5.2]
  def change
    add_column :barito_apps, :log_count, :integer, default: 0
  end
end
