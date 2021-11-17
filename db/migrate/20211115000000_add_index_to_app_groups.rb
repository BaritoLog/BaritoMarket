class AddIndexToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_index :app_groups, :name
  end
end