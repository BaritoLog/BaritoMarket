FactoryGirl.define do
  factory :group do
    name 'group_name'
    receiver_host 'host'
    zookeeper_hosts 'host'
    kafka_broker_hosts 'host'
  end
end