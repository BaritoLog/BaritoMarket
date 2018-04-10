FactoryGirl.define do
  factory :log_template do
    name "template1"
    tps_limit 1
    zookeeper_instances 1
    kafka_instances 1
    es_instances 1
  end
end
