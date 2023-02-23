class AddLatestCostToBaritoApp < ActiveRecord::Migration[5.2]
  def change
    add_column :barito_apps, :latest_cost, :integer
    add_column :barito_apps, :latest_ingested_log_bytes, :integer
  end
end
