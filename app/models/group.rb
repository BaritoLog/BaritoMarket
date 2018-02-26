class Group < ActiveRecord::Base
  validates_presence_of :name, :receiver_host, :zookeeper_hosts, :kafka_broker_hosts
end
