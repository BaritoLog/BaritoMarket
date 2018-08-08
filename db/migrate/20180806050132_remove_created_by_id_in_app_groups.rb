class RemoveCreatedByIdInAppGroups < ActiveRecord::Migration[5.2]
  def change
    remove_column :app_groups, :created_by_id, :bigint
  end
end
