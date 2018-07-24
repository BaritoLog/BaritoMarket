class AddCreatedByIdToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :created_by_id, :bigint
    add_index :app_groups, :created_by_id
    add_foreign_key :app_groups, :users, column: :created_by_id
  end
end
