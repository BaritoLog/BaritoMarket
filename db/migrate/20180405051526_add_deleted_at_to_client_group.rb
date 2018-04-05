class AddDeletedAtToClientGroup < ActiveRecord::Migration
  def change
    add_column :client_groups, :deleted_at, :datetime
    add_index :client_groups, :deleted_at
  end
end
