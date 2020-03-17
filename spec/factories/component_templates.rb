FactoryBot.define do
  factory :component_template do
    name                  Faker::Lorem.word
    bootstrappers       {
                          [{
                            "bootstrap_type": "chef-solo",
                            "bootstrap_cookbooks_url": "",
                            "bootstrap_attributes": {
                              "consul": {
                                "hosts": []
                              },
                              "run_list": []
                            }
                          }]
                        }
  end
end
