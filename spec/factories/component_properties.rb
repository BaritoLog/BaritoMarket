FactoryBot.define do
  factory :component_property do
    name                  %w(yggdrasil consul kibana yggdrasil zookeeper elasticsearch barito-flow-consumer barito-flow-producer).sample
    component_attributes  "{\n  
                              \"consul\": {\n    
                                  \"hosts\": [\n\"172.20.10.252\"\n],\n    
                                  \"config\": {\n      
                                      \"consul.json\": {\n        
                                          \"bind_addr\": \"172.20.10.252\"\n      
                                        }\n    
                                    }\n  
                              },\n  
                              \"run_list\": [\n\"role[consul]\"\n]\n
                            }"
  end
end
