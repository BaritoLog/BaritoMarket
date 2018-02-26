class Forwarder < ActiveRecord::Base
  validates_presence_of :name, :host, :group_id, :store_id, :kafka_topics

  belongs_to :group, required: true
  belongs_to :store, required: true


end
