class CreateBaritoApps < ActiveRecord::Migration[5.2]
  def change
    create_table :barito_apps do |t|
      t.string :name
      t.string :app_group
      t.string :tps_config
      t.string :secret_key
      t.string :cluster_name
      t.string :app_status
      t.string :setup_status
      t.timestamps null: false
    end
  end
end
