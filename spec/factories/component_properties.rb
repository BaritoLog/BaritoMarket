FactoryBot.define do
  factory :component_property do
    name                  %w(yggdrasil consul kibana yggdrasil zookeeper elasticsearch barito-flow-consumer barito-flow-producer).sample
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
