FactoryBot.define do
  factory :component_template do
    name                  Faker::Lorem.word
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
