class AddRoleToGroupUser < ActiveRecord::Migration[5.2]
  def change
    add_column :group_users, :role_id, :bigint
    add_foreign_key :group_users, :app_group_roles, column: :role_id
  end
end
