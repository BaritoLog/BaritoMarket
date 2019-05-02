FactoryBot.define do
  factory :component_template do
    name                  %w(yggdrasil consul kibana kafka zookeeper elasticsearch barito-flow-consumer barito-flow-producer).sample
    image                 Faker::Lorem.word
    component_attributes  { {
                            "consul": 
                              {
                                "hosts": [], 
                                "config": {
                                  "consul.json": {"bind_addr": ""}
                              }
                            }, 
                            "run_list": []
                          } }
  end
end
