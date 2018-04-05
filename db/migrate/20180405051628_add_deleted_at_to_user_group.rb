class AddDeletedAtToUserGroup < ActiveRecord::Migration
  def change
    add_column :user_groups, :deleted_at, :datetime
    add_index :user_groups, :deleted_at
  end
end
