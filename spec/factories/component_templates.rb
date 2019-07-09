FactoryBot.define do
  factory :component_template do
    name                  Faker::Lorem.word
    source                { {
                            "source_type": "image",       # can be image, migration or copy
                            "mode": "pull",              # can be local or pull. default is pull.
                            "remote": {
                              "name": "barito-registry"
                            },
                            "fingerprint": "",
                            "alias": "lxd-consul-1.1.0-3"
                          } }
    bootstrappers       {
                          [{    
                            "bootstrap_type": "chef-solo",
                            "bootstrap_cookbooks_url": "",
                            "bootstrap_attributes": {
                              "consul": {
                                "hosts": [],
                                "config": {"consul.json": {"bind_addr": ""}}
                              },
                              "run_list": []
                            } 
                          }]
                        }    
  end
end
