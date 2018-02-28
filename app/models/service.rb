class Service < ActiveRecord::Base
  validates_presence_of :name, :group_id, :store_id

  belongs_to :group, required: true
  belongs_to :store, required: true
  belongs_to :forwarder, required: true

  after_create :copy_kafka_topics_from_forwarder

  private
  def copy_kafka_topics_from_forwarder
    update_column(:kafka_topics, self.forwarder.kafka_topics)
  end

end
