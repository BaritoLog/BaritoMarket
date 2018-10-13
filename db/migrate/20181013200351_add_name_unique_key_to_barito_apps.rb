class AddNameUniqueKeyToBaritoApps < ActiveRecord::Migration[5.2]
  def change
    add_index :barito_apps, [:app_group_id, :name], unique: true
    add_index :barito_apps, [:app_group_id, :topic_name], unique: true
  end
end
