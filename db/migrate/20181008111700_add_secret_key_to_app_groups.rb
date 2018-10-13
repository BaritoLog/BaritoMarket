class AddSecretKeyToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :secret_key, :string

    add_index :app_groups, :secret_key
  end
end
