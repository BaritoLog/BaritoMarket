class LogTemplate < ActiveRecord::Base
  validates :name, presence: true
  validates :tps_limit, presence: true, numericality: {greater_than: 0}
  validates :zookeeper_instances, presence: true, numericality: {greater_than: 0}
  validates :kafka_instances, presence: true, numericality: {greater_than: 0}
  validates :es_instances, presence: true, numericality: {greater_than: 0}
  validates :consul_instances, presence: true, numericality: {greater_than: 0}
  validates :yggdrasil_instances, presence: true, numericality: {greater_than: 0}
  validates :kibana_instances, presence: true, numericality: {greater_than: 0}

  def name_with_tps
    "#{name.camelize} (#{tps_limit} trx/sec)"
  end
end
