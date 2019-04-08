FactoryBot.define do
  factory :cluster_template do
    sequence(:name) { |n| "#{Faker::Cat.name} #{n}" }
    instances       { 
                      [
                        {
                          "type": "yggdrasil",
                          "count": 0
                        },
                        {
                          "type": "consul",
                          "count": 1
                        },
                        {
                          "type": "zookeeper",
                          "count": 1
                        },
                        {
                          "type": "kafka",
                          "count": 1
                        },
                        {
                          "type": "elasticsearch",
                          "count": 1
                        },
                        {
                          "type": "barito-flow-producer",
                          "count": 1
                        },
                        {
                          "type": "barito-flow-consumer",
                          "count": 1
                        },
                        {
                          "type": "kibana",
                          "count": 1
                        }
                      ]
                    }
    options   { {"kafka_partition": 1, "kafka_replication_factor": 1, "max_tps": 100} }
  end
end
