FactoryBot.define do
  factory :infrastructure do
    name                  Faker::Lorem.word
    cluster_name          Rufus::Mnemo.from_i(1000)
    capacity              %w(small medium large).sample
    provisioning_status   Infrastructure.provisioning_statuses[:pending]
    status                Infrastructure.statuses[:inactive]
    consul_host           Faker::Internet.domain_name
    options               { {"kafka_partition": 1, "kafka_replication_factor": 1, "max_tps": 100} }
    association           :app_group
    association           :cluster_template
    manifests             {
                            [
                              {
                                "type": "consul",
                                "count": 1,
                                "min_available_count" => 0,
                                "definition": {
                                  "container_type": "stateless",
                                  "strategy": "RollingUpdate",
                                  "allow_failure": "false",
                                  "source": {
                                    "mode": "pull",              # can be local or pull. default is pull.
                                    "alias": "lxd-ubuntu-minimal-consul-1.1.0-8",
                                    "remote": {
                                      "name": "barito-registry"
                                    },
                                    "fingerprint": "",
                                    "source_type": "image"                      
                                  },
                                  "resource": {
                                    "cpu_limit": "0-2",
                                    "mem_limit": "500MB"
                                  },
                                  "bootstrappers": [{
                                    "bootstrap_type": "chef-solo",
                                    "bootstrap_attributes": {
                                      "consul": {
                                        "hosts": []
                                      },
                                      "run_list": []
                                    },
                                    "bootstrap_cookbooks_url": "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
                                  }],
                                  "healthcheck": {
                                    "type": "tcp",
                                    "port": 9500,
                                    "endpoint": "",
                                    "payload": "",
                                    "timeout": ""
                                  }
                                }
                              }
                            ]
                          }
  end
end
