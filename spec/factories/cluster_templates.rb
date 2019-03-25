FactoryBot.define do
  factory :cluster_template do
    env             %w(staging integration production).sample
    name            Faker::Lorem.word.underscore
    max_tps         [100, 500, 1000].sample
    instances       { 
                      {
                        "yggdrasil": {"name": "yggdrassil", "count": 1, "seq": 0}, 
                        "consul": {"name": "consul", "count": 1, "seq": 1}, 
                        "zookeeper": {"name": "zookeeper", "count": 1, "seq": 2}, 
                        "kafka": {"name": "kafka", "count": 1, "seq": 3}, 
                        "elasticsearch": {"name": "elasticsearch", "count": 1, "seq": 4}, 
                        "barito-flow-producer": {"name": "barito-flow-producer", "count": 1, "seq": 5}, 
                        "barito-flow-consumer": {"name": "barito-flow-consumer", "count": 1, "seq": 6}, 
                        "kibana": {"name": "kibana", "count": 1, "seq": 7}
                      }
                    }
    kafka_options   { {"partition": 1, "replication_factor": 1} }
  end
end
