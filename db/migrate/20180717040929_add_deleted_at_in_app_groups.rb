class AddDeletedAtInAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :deleted_at, :datetime
  end
end
