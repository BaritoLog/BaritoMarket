class AddStatusToApp < ActiveRecord::Migration
  def change
    add_column :apps, :setup_status, :string, :default => "PENDING"
    add_index :apps, :setup_status
    add_column :apps, :app_status, :string, :default => "INACTIVE", :index => true
    add_index :apps, :app_status
  end
end
