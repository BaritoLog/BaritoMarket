class LogTemplate < ActiveRecord::Base
  validates :name, presence: true
  validates :tps_limit, presence: true, numericality: {greater_than: 0}
  validates :zookeeper_instances, presence: true, numericality: {greater_than: 0}
  validates :kafka_instances, presence: true, numericality: {greater_than: 0}
  validates :es_instances, presence: true, numericality: {greater_than: 0}
end