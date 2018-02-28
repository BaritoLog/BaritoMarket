class Service < ActiveRecord::Base
  validates_presence_of :name, :group_id, :store_id

  belongs_to :group, required: true
  belongs_to :store, required: true
  belongs_to :forwarder, required: true

  after_create :copy_kafka_topics_from_forwarder, :generate_produce_url

  private
  def copy_kafka_topics_from_forwarder
    update_column(:kafka_topics, self.forwarder.kafka_topics)
  end

  def generate_produce_url
    produce_url = "http://#{self.group.receiver_host}/gp/#{self.group_id}/st/#{self.store_id}/fw/#{self.forwarder_id}/sv/#{self.id}/produce/#{self.kafka_topics}"
    update_column(:produce_url, produce_url)
  end
end
