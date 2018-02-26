class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.text :description
      t.integer :group_id
      t.integer :store_id
      t.string :produce_url
      t.string :kibana_host
      t.string :kafka_topics
      t.integer :kafka_topic_partition
      t.string :heartbeat_url

      t.timestamps null: false
    end
  end
end
