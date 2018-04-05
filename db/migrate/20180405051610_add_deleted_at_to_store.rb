class AddDeletedAtToStore < ActiveRecord::Migration
  def change
    add_column :stores, :deleted_at, :datetime
    add_index :stores, :deleted_at
  end
end
