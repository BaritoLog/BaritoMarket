class RenameTableGroupToStream < ActiveRecord::Migration
  def change
    rename_table :groups, :streams
    rename_column :forwarders, :group_id, :stream_id
    rename_column :services, :group_id, :stream_id
  end
end
