FactoryGirl.define do
  factory :service do
    name 'name1'

    stream
    store
    forwarder
  end
end
