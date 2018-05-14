class AddClusterNameToApps < ActiveRecord::Migration
  def change
    add_column :apps, :cluster_name, :string
  end
end
