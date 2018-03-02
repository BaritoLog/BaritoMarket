class Stream < ActiveRecord::Base
  validates_presence_of :name, :receiver_host, :zookeeper_hosts, :kafka_broker_hosts, :kafka_topic_partition, :receiver_port

  validate :validate_kafka_topic_partition_number

  after_create :create_receiver_databag

  private
  def validate_kafka_topic_partition_number
    kafka_broker_number = self.kafka_broker_hosts.split(",").size
    if !kafka_topic_partition.nil? && kafka_topic_partition < kafka_broker_number
      errors.add(:kafka_topic_partition, "must be greater than kafka broker host number (#{kafka_broker_number})")
    end
  end

  def create_receiver_databag
    data = {
        :kafka_broker_hosts => self.kafka_broker_hosts,
        :zookeeper_hosts => self.zookeeper_hosts,
        :receiver_port => self.receiver_port
    }

    databag = Databag.create(ip_address: self.receiver_host, data: data.to_json, tags: 'receiver')

    update_column(:databag_id, databag.id)
  end

end
