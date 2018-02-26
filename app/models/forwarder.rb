class Forwarder < ActiveRecord::Base
  validates_presence_of :name, :host, :group_id, :store_id, :kafka_topics

  belongs_to :group, required: true
  belongs_to :store, required: true

  after_save :set_kafka_and_zookeeper

  private

  def set_kafka_and_zookeeper
    update_column(:kafka_broker_hosts, self.group.kafka_broker_hosts)
    update_column(:zookeeper_hosts, self.group.zookeeper_hosts)
  end
end
