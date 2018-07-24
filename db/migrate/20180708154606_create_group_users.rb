class CreateGroupUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :group_users do |t|
      t.references :group, index: true
      t.references :user, index: true
      t.timestamps null: false
    end
  end
end
