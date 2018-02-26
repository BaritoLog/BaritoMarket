class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.string :receiver_host
      t.string :zookeeper_hosts
      t.string :kafka_broker_hosts
      t.string :receiver_heartbeat_url
      t.string :kafka_manager_host

      t.timestamps null: false
    end
  end
end
