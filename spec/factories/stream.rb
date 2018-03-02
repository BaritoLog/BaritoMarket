FactoryGirl.define do
  factory :stream do
    name 'stream_name'
    receiver_host 'host'
    receiver_port '1234'
    zookeeper_hosts 'host'
    kafka_broker_hosts 'host'
    kafka_topic_partition 10
  end
end
