FactoryGirl.define do
  factory :client do
    name 'name1'

    stream
    store
    forwarder
    user
  end
end
