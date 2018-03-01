FactoryGirl.define do
  factory :databag do

    json = { :some_config => 'some_value' }.to_json
    ip_address '127.0.0.1'
    data json
    tags 'some_tag,some_tag2'
  end
end
