class CreateServiceConfigs < ActiveRecord::Migration
  def change
    create_table :service_configs do |t|
      t.string :ip_address
      t.json :config_json

      t.timestamps null: false
    end
  end
end
