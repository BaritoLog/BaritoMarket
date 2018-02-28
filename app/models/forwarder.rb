class Forwarder < ActiveRecord::Base
  validates_presence_of :name, :host, :kafka_topics

  belongs_to :group
  belongs_to :store

  def set_group_and_store(group, store)
    self.group = group
    self.store = store

    self.kafka_broker_hosts = group.kafka_broker_hosts
    self.zookeeper_hosts = group.zookeeper_hosts

    self.save!
  end
end
