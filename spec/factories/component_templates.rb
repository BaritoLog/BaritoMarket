FactoryBot.define do
  factory :component_template do
    env             %w(staging integration production).sample
    name            Faker::Lorem.word.underscore
    max_tps         [100, 500, 1000].sample
    instances       "{\r\n  
                        \"kafka\": {\r\n    \"seq\": 3,\r\n    \"count\": 3\r\n  },\r\n  
                        \"consul\": {\r\n    \"seq\": 1,\r\n    \"count\": 1\r\n  },\r\n  
                        \"kibana\": {\r\n    \"seq\": 7,\r\n    \"count\": 1\r\n  },\r\n  
                        \"yggdrasil\": {\r\n    \"seq\": 0,\r\n    \"count\": 1\r\n  },\r\n  
                        \"zookeeper\": {\r\n    \"seq\": 2,\r\n    \"count\": 1\r\n  },\r\n  
                        \"elasticsearch\": {\r\n    \"seq\": 4,\r\n    \"count\": 1\r\n  },\r\n  
                        \"barito-flow-consumer\": {\r\n    \"seq\": 6,\r\n    \"count\": 1\r\n  },\r\n  
                        \"barito-flow-producer\": {\r\n    \"seq\": 5,\r\n    \"count\": 1\r\n  }\r\n
                    }"
    kafka_options   "{\r\n  \"partition\": 1,\r\n  \"replication_factor\": 1\r\n}"
  end
end
