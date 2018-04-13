class AddNewColumnToApps < ActiveRecord::Migration
  def change
    add_column :apps, :secret_key, :string
    add_column :apps, :kibana_address, :string
    add_column :apps, :receiver_end_point, :string
  end
end
