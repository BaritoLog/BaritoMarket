class CreateLogTemplates < ActiveRecord::Migration
  def change
    create_table :log_templates do |t|
      t.string :name
      t.integer :tps_limit
      t.integer :zookeeper_instances
      t.integer :kafka_instances
      t.integer :es_instances

      t.timestamps null: false
    end
  end
end
