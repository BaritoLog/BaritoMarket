class CreateForwarders < ActiveRecord::Migration
  def change
    create_table :forwarders do |t|
      t.string :name
      t.string :host
      t.integer :group_id
      t.integer :store_id
      t.string :kafka_broker_hosts
      t.string :zookeeper_hosts
      t.string :kafka_topics
      t.string :heartbeat_url

      t.timestamps null: false
    end
  end
end
