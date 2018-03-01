FactoryGirl.define do
  factory :service_config do

    json = { :some_config => 'some_value' }.to_json
    ip_address '127.0.0.1'
    config_json json
    tags 'some_tag,some_tag2'
  end
end