class AddIndexToBaritoApps < ActiveRecord::Migration[5.2]
  def change
    add_index :barito_apps, :secret_key
    add_index :barito_apps, :status
  end
end
