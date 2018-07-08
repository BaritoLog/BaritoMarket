class CreateAppGroupAdmins < ActiveRecord::Migration[5.2]
  def change
    create_table :app_group_admins do |t|
      t.references :app_group, index: true
      t.references :user, index: true
      t.timestamps null: false
    end

    add_index :app_group_admins, [:app_group_id, :user_id], unique: true
  end
end
