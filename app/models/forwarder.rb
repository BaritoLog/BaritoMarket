class Forwarder < ActiveRecord::Base
  acts_as_paranoid
  validates_presence_of :name, :host, :kafka_topics

  belongs_to :stream
  belongs_to :store

  def set_stream_and_store(stream, store)
    self.stream = stream
    self.store = store

    self.kafka_broker_hosts = stream.kafka_broker_hosts
    self.zookeeper_hosts = stream.zookeeper_hosts

    self.save!
  end
end
