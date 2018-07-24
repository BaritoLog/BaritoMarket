class CreateAppGroupUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :app_group_users do |t|
      t.references :app_group, index: true
      t.references :user, index: true
      t.references :role, index: true
      t.timestamps null: false
    end

    add_index :app_group_users, [:app_group_id, :user_id, :role_id], unique: true
  end
end
