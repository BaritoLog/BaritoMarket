FactoryBot.define do
  factory :cluster_template do
    name            %w(Staging Integration Production).sample
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
