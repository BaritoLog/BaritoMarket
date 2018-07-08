class AddUserIdToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_reference :app_groups, :user, index: true
    add_column :users, :admin, :boolean, default: false, null: false
    add_column :users, :auth_token, :string
  end
end
