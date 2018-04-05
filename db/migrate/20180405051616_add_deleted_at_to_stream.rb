class AddDeletedAtToStream < ActiveRecord::Migration
  def change
    add_column :streams, :deleted_at, :datetime
    add_index :streams, :deleted_at
  end
end
