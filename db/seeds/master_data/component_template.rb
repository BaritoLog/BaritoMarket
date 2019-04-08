
# Fetch dependency
# -----------------------------------------------------------------------------

# Seeds
# -----------------------------------------------------------------------------

ComponentTemplate.create!(
  name: "consul",
  component_attributes: {
    "consul": 
      {
        "hosts": [], 
        "config": {
          "consul.json": {"bind_addr": ""}
      }
    }, 
    "run_list": []
  }
)
ComponentTemplate.create!(
  name: "zookeeper",
  component_attributes: {
    "consul":{
      "hosts":[],
      "config":{"consul.json":{"bind_addr":""}},
      "run_as_server":false
    },
    "datadog":{
      "zk":{
        "instances":[{"host":"localhost", "port":2181, "tags":[], "cluster_name":""}]
      },
      "datadog_api_key":"",
      "datadog_hostname":""
    },
    "run_list":[],
    "zookeeper":{"hosts":[""],"my_id":""}
  }
)
ComponentTemplate.create!(
  name: "kafka",
  component_attributes: {
    "kafka":{
      "kafka":{"hosts":[]}, 
      "zookeeper":{"hosts":[]}
    }, 
    "consul":{
      "hosts":[], 
      "config":{"consul.json":{"bind_addr":""}}, 
      "run_as_server":false
    }, 
    "datadog":{
      "kafka":{
        "instances":[{"host":"localhost", "port":8090, "tags":[], "cluster_name":""}]
      }, 
      "datadog_api_key":"", 
      "datadog_hostname":""
    }, 
    "run_list":[]
  }
)
ComponentTemplate.create!(
  name: "elasticsearch",
  component_attributes: {
    "consul":{
      "hosts":[], 
      "config":{"consul.json":{"bind_addr":""}}, 
      "run_as_server":false
    }, 
    "datadog":{
      "elastic":{
        "instances":[{"url":"", "tags":[]}]
      }, 
      "datadog_api_key":"", 
      "datadog_hostname":""
    }, 
    "run_list":[], 
    "elasticsearch":{
      "version":"6.3.0", 
      "allocated_memory":12000000, 
      "max_allocated_memory":16000000, 
      "cluster_name":"", 
      "index_number_of_replicas":0
    }
  }
)
ComponentTemplate.create!(
  name: "barito-flow-producer",
  component_attributes: {
    "consul":{
      "hosts":[], 
      "config":{"consul.json":{"bind_addr":""}}, 
      "run_as_server":false
    }, 
    "run_list":[], 
    "barito-flow":{
      "producer":{
        "version":"v0.11.8", 
        "env_vars":{
          "BARITO_PRODUCER_ADDRESS":":8080",
          "BARITO_CONSUL_URL":"", 
          "BARITO_CONSUL_KAFKA_NAME":"kafka", 
          "BARITO_KAFKA_BROKERS":"", 
          "BARITO_KAFKA_PRODUCER_TOPIC":"barito-log",
          "BARITO_PRODUCER_MAX_TPS":0, 
          "BARITO_PRODUCER_RATE_LIMIT_RESET_INTERVAL":10
        }
      }
    }
  }
)
ComponentTemplate.create!(
  name: "barito-flow-consumer",
  component_attributes: {
    "consul":{
      "hosts":[], 
      "config":{"consul.json":{"bind_addr":""}}, 
      "run_as_server":false
    }, 
    "run_list":[], 
    "barito-flow":{
      "consumer":{
        "version":"v0.11.8", 
        "env_vars":{
          "BARITO_CONSUL_URL":"",
          "BARITO_CONSUL_KAFKA_NAME":"kafka", 
          "BARITO_CONSUL_ELASTICSEARCH_NAME":"elasticsearch",
          "BARITO_KAFKA_BROKERS":"", 
          "BARITO_KAFKA_GROUP_ID":"barito-group", 
          "BARITO_KAFKA_CONSUMER_TOPICS":"barito-log", 
          "BARITO_ELASTICSEARCH_URL":"", 
          "BARITO_PUSH_METRIC_URL":""
        }
      }
    }
  }
)
ComponentTemplate.create!(
  name: "kibana",
  component_attributes: {
    "consul":{
      "hosts":[], 
      "config":{"consul.json":{"bind_addr":""}}, 
      "run_as_server":false
    },
    "kibana":{
      "config":{
        "server.basePath":"", 
        "elasticsearch.url":""
      }, 
      "version":"6.3.0"
    }, 
    "run_list":[]
  }
)
