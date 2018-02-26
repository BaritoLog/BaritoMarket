FactoryGirl.define do
  factory :forwarder do
    name 'name1'
    host 'host1'
    kafka_topics 'topic1'

    group
    store
  end
end