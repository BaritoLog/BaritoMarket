class AddTopicPartitionNumberToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :kafka_topic_partition, :integer, default: false, null: false unless column_exists? :groups, :kafka_topic_partition
  end
end
