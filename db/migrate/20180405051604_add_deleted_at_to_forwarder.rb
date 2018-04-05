class AddDeletedAtToForwarder < ActiveRecord::Migration
  def change
    add_column :forwarders, :deleted_at, :datetime
    add_index :forwarders, :deleted_at
  end
end
