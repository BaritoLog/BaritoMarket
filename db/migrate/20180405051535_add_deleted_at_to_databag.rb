class AddDeletedAtToDatabag < ActiveRecord::Migration
  def change
    add_column :databags, :deleted_at, :datetime
    add_index :databags, :deleted_at
  end
end
