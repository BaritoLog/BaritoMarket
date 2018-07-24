class CreateAppGroupRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :app_group_roles do |t|
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
