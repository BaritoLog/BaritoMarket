# Default dummy seeds

::FactoryBot.create(:group, name: "barito-superadmin")
::FactoryBot.create(:group, name: Figaro.env.global_viewer_role)
%w(yggdrasil consul zookeeper kafka elasticsearch barito-flow-producer barito-flow-consumer kibana).each do |n|
  case n
  when "consul"
    ::FactoryBot.create(:component_template,
      name: n,
      source: {
        source_type: "image",       # can be image, migration or copy
        mode: "pull",              # can be local or pull. default is pull.
        remote: {
          name: "barito-registry"
        },
        fingerprint: "",
        alias: "lxd-consul-1.1.0-3"
      },
      bootstrappers: [{    
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/consul-cookbook/archive/master.tar.gz",
          bootstrap_attributes: {
            "consul": {
                "hosts": [

                ],
                "config": {
                "consul.json": {
                    "bind_addr": ""
                }
                }
            },
            "run_list": []
          }
      }]
    )
  when "zookeeper"
    ::FactoryBot.create(:component_template,
      name: n,
      source: {
        source_type: "image",       # can be image, migration or copy
        mode: "pull",              # can be local or pull. default is pull.
        remote: {
          name: "barito-registry"
        },
        fingerprint: "",
        alias: "lxd-zookeeper-3.4.12-1"
      },
      bootstrappers: [{    
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/zookeeper-cookbook/archive/master.tar.gz",
          bootstrap_attributes: {
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
      }]
    )
  when "kafka"
    ::FactoryBot.create(:component_template,
      name: n,
      source: {
        source_type: "image",       # can be image, migration or copy
        mode: "pull",              # can be local or pull. default is pull.
        remote: {
          name: "barito-registry"
        },
        fingerprint: "",
        alias: "lxd-kafka-2.11-1"
      },
      bootstrappers: [{    
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/kafka-cookbook/archive/master.tar.gz",
          bootstrap_attributes: {
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
      }]
    )
  when "elasticsearch"
    ::FactoryBot.create(:component_template,
      name: n,
      source: {
        source_type: "image",       # can be image, migration or copy
        mode: "pull",              # can be local or pull. default is pull.
        remote: {
          name: "barito-registry"
        },
        fingerprint: "",
        alias: "lxd-elasticsearch-6.4.1-1"
      },
      bootstrappers: [{    
        bootstrap_type: "chef-solo",
        bootstrap_cookbooks_url: "https://github.com/BaritoLog/elasticsearchwrapper_cookbook/archive/master.tar.gz",
        bootstrap_attributes: {
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
      }]
    )
  when "barito-flow-producer"
    ::FactoryBot.create(:component_template,
      name: n,
      source: {
        source_type: "image",       # can be image, migration or copy
        mode: "pull",              # can be local or pull. default is pull.
        remote: {
          name: "barito-registry"
        },
        fingerprint: "",
        alias: "lxd-barito-flow-producer-0.8.0-1"
      },
      bootstrappers: [{    
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/barito-flow-cookbook/archive/master.tar.gz",
          bootstrap_attributes: {
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
      }]
    )
  when "barito-flow-consumer"
    ::FactoryBot.create(:component_template,
      name: n,
      source: {
        source_type: "image",       # can be image, migration or copy
        mode: "pull",              # can be local or pull. default is pull.
        remote: {
          name: "barito-registry"
        },
        fingerprint: "",
        alias: "lxd-barito-flow-consumer-0.8.0-1"
      },
      bootstrappers: [{    
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/barito-flow-cookbook/archive/master.tar.gz",
          bootstrap_attributes: {
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
      }]
    )
  when "kibana"
    ::FactoryBot.create(:component_template,
      name: n,
      source: {
        source_type: "image",       # can be image, migration or copy
        mode: "pull",              # can be local or pull. default is pull.
        remote: {
          name: "barito-registry"
        },
        fingerprint: "",
        alias: "lxd-kibana-6.3.0-1"
      },
      bootstrappers: [{    
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/kibana_wrapper_cookbook",
          bootstrap_attributes: {
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
      }]
    )
  else
    ::FactoryBot.create(:component_template, name: n)
  end
end