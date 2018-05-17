class AddConsulToApps < ActiveRecord::Migration
  def change
    add_column :apps, :consul, :string
  end
end
