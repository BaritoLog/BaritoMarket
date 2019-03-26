FactoryBot.define do
  factory :cluster_template do
    env             %w(staging integration production).sample
    name            Faker::Lorem.word.underscore
    max_tps         [100, 500, 1000].sample
    instances       { 
                      [
                        {
                          "name": "yggdrasil",
                          "count": 0
                        },
                        {
                          "name": "consul",
                          "count": 1
                        },
                        {
                          "name": "zookeeper",
                          "count": 1
                        },
                        {
                          "name": "kafka",
                          "count": 1
                        },
                        {
                          "name": "elasticsearch",
                          "count": 1
                        },
                        {
                          "name": "barito-flow-producer",
                          "count": 1
                        },
                        {
                          "name": "barito-flow-consumer",
                          "count": 1
                        },
                        {
                          "name": "kibana",
                          "count": 1
                        }
                      ]
                    }
    kafka_options   { {"partition": 1, "replication_factor": 1} }
  end
end
