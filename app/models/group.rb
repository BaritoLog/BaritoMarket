class Group < ActiveRecord::Base
  validates_presence_of :name, :receiver_host, :zookeeper_hosts, :kafka_broker_hosts, :kafka_topic_partition

  validate :validate_kafka_topic_partition_number

  private
  def validate_kafka_topic_partition_number
    kafka_broker_number = self.kafka_broker_hosts.split(",").size
    if !kafka_topic_partition.nil? && kafka_topic_partition < kafka_broker_number
      errors.add(:kafka_topic_partition, "must be greater than kafka broker host number (#{kafka_broker_number})")
    end
  end

end
