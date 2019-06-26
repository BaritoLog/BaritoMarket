FactoryBot.define do
  factory :infrastructure_component do
    association     :infrastructure
    hostname        Faker::Lorem.word
    component_type  Faker::Lorem.word.underscore
    message         Faker::Lorem.sentence
    status          InfrastructureComponent.statuses[:pending]
    source         { {
                      "source_type": "image",       # can be image, migration or copy
                      "mode": "pull",              # can be local or pull. default is pull.
                      "remote": {
                        "name": "barito-registry"
                      },
                      "fingerprint": "",
                      "alias": "lxd-consul-1.1.0-3"
                    } }
    bootstrappers   {
                      [{    
                        "bootstrap_type": "chef-solo",
                        "bootstrap_cookbooks_url": "https://github.com/BaritoLog/consul-cookbook/archive/master.tar.gz",
                        "bootstrap_attributes": {
                          "consul": {
                            "hosts": [],
                            "config": {"consul.json": {"bind_addr": ""}}
                          },
                          "run_list": []
                        } 
                      }]
                    }
    sequence(:sequence, (1..10).cycle){ |n| n}
  end
end
