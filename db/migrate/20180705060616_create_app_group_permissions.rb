class CreateAppGroupPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :app_group_permissions do |t|
      t.references :app_group, index: true
      t.references :group, index: true
      t.timestamps null: false
    end

    add_index :app_group_permissions, [:app_group_id, :group_id], unique: true
  end
end
