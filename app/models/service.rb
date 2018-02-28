class Service < ActiveRecord::Base
  validates_presence_of :name, :group_id, :store_id

  belongs_to :group, required: true
  belongs_to :store, required: true
  belongs_to :forwarder, required: true

  after_create :copy_kafka_topics_from_forwarder, :generate_produce_url, :setup_forwarder, :copy_kibana_host_from_store, :copy_kafka_topic_partiion_from_group

  private
  def copy_kafka_topics_from_forwarder
    update_column(:kafka_topics, self.forwarder.kafka_topics)
  end

  def generate_produce_url
    produce_url = "http://#{self.group.receiver_host}/gp/#{self.group_id}/st/#{self.store_id}/fw/#{self.forwarder_id}/sv/#{self.id}/produce/#{self.kafka_topics}"
    update_column(:produce_url, produce_url)
  end

  def setup_forwarder
    self.forwarder.set_group_and_store(self.group, self.store)
  end

  def copy_kibana_host_from_store
    update_column(:kibana_host, self.store.kibana_host)
  end

  def copy_kafka_topic_partiion_from_group
    update_column(:kafka_topic_partition, self.group.kafka_topic_partition)
  end
end
