
# Fetch dependency
# -----------------------------------------------------------------------------

# Seeds
# -----------------------------------------------------------------------------

### Staging
ClusterTemplate.create!(
  name: "Log - Small",
  manifests: [
              {
                "type": "consul",
                "desired_num_replicas": 1,
                "min_available_replicas": 0,
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
              },
              {
                "type": "zookeeper",
                "desired_num_replicas": 1,
                "min_available_replicas": 0,
                "definition": {
                  "container_type": "stateless",
                  "strategy": "RollingUpdate",
                  "allow_failure": "false",
                  "resource": {
                    "cpu_limit": "0-2",
                    "mem_limit": "5GB"
                  },
                  "source": {
                    "mode": "pull",              # can be local or pull. default is pull.
                    "alias": "lxd-ubuntu-minimal-zookeeper-3.4.12-3",
                    "remote": {
                      "name": "barito-registry"
                    },
                    "fingerprint": "",
                    "source_type": "image"                      
                  },
                  "bootstrappers": [{
                    "bootstrap_type": "chef-solo",
                    "bootstrap_attributes": {
                      "consul": {
                        "hosts": [

                        ],
                        "run_as_server": false
                      },
                      "run_list": [

                      ],
                      "zookeeper": {
                        "hosts": [
                          ""
                        ],
                        "my_id": ""
                      }
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
              },
              {
                "type": "kafka",
                "desired_num_replicas": 1,
                "min_available_replicas": 0,
                "definition": {
                  "container_type": "stateful",
                  "strategy": "RollingUpdate",
                  "allow_failure": "false",
                  "source": {
                    "mode": "pull",              # can be local or pull. default is pull.
                    "alias": "lxd-ubuntu-minimal-kafka-2.11-8",
                    "remote": {
                      "name": "barito-registry"
                    },
                    "fingerprint": "",
                    "source_type": "image"                      
                  },
                  "resource": {
                    "cpu_limit": "1-4",
                    "mem_limit": "10GB"
                  },
                  "bootstrappers": [{
                    "bootstrap_type": "chef-solo",
                    "bootstrap_attributes": {
                      "kafka": {
                        "kafka": {
                          "hosts": [],
                          "hosts_count": 1
                        },
                        "zookeeper": {
                          "hosts": []
                        },
                        "scala_version": "2.11",
                        "confluent_version": "5.3.0"
                      },
                      "consul": {
                        "hosts": [],
                        "run_as_server": false
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
              },
              {
                "type": "elasticsearch",
                "desired_num_replicas": 1,
                "min_available_replicas": 0,
                "definition": {
                  "container_type": "stateful",
                  "strategy": "RollingUpdate",
                  "allow_failure": "false",
                  "source": {
                    "mode": "pull",              # can be local or pull. default is pull.
                    "alias": "lxd-ubuntu-minimal-elasticsearch-6.8.5-1",
                    "remote": {
                      "name": "barito-registry"
                    },
                    "fingerprint": "",
                    "source_type": "image"                      
                  },
                  "resource": {
                    "cpu_limit": "1-4",
                    "mem_limit": "20GB"
                  },
                  "bootstrappers": [{
                    "bootstrap_type": "chef-solo",
                    "bootstrap_attributes": {
                      "consul": {
                        "hosts": [],
                        "run_as_server": false
                      },
                      "run_list": [],
                      "elasticsearch": {
                        "version": "6.8.5",
                        "memory_lock": false,
                        "node_master": true,
                        "cluster_name": "",
                        "allocated_memory": 12000000,
                        "max_allocated_memory": 16000000,
                        "minimum_master_nodes": 1,
                        "index_number_of_replicas": 1
                      }
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
              },
              {
                "type": "barito-flow-producer",
                "desired_num_replicas": 1,
                "min_available_replicas": 0,
                "definition": {
                  "container_type": "stateless",
                  "strategy": "RollingUpdate",
                  "allow_failure": "false",
                  "source": {
                    "mode": "pull",              # can be local or pull. default is pull.
                    "alias": "lxd-ubuntu-minimal-barito-flow-producer-0.13.2-2",
                    "remote": {
                      "name": "barito-registry"
                    },
                    "fingerprint": "",
                    "source_type": "image"                      
                  },
                  "resource": {
                    "cpu_limit": "1-4",
                    "mem_limit": "20GB"
                  },
                  "bootstrappers": [{
                    "bootstrap_type": "chef-solo",
                    "bootstrap_attributes": {
                      "consul": {
                        "hosts": [],
                        "run_as_server": false
                      },
                      "run_list": [],
                      "barito-flow": {
                        "producer": {
                          "version": "v0.13.2",
                          "env_vars": {
                            "BARITO_CONSUL_URL": "",
                            "BARITO_KAFKA_BROKERS": "kafka.service.consul:9092",
                            "BARITO_PRODUCER_GRPC": ":8080",
                            "BARITO_PRODUCER_REST": ":8085",
                            "BARITO_PRODUCER_ADDRESS": ":8081",
                            "BARITO_PRODUCER_MAX_TPS": 0,
                            "BARITO_CONSUL_KAFKA_NAME": "kafka",
                            "BARITO_PRODUCER_REST_API": "false",
                            "BARITO_KAFKA_TOPIC_SUFFIX": "_pb",
                            "BARITO_KAFKA_PRODUCER_TOPIC": "barito-log",
                            "BARITO_PRODUCER_RATE_LIMIT_RESET_INTERVAL": 10
                          }
                        }
                      }
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
              },
              {
                "type": "barito-flow-consumer",
                "desired_num_replicas": 1,
                "min_available_replicas": 0,
                "definition": {
                  "container_type": "stateless",
                  "strategy": "RollingUpdate",
                  "allow_failure": "false",
                  "source": {
                    "mode": "pull",              # can be local or pull. default is pull.
                    "alias": "lxd-ubuntu-minimal-barito-flow-consumer-0.13.2-2",
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
                        "hosts": [

                        ],
                        "config": {
                          "consul.json": {
                            "bind_addr": ""
                          }
                        },
                        "run_as_server": false
                      },
                      "run_list": [

                      ],
                      "barito-flow": {
                        "consumer": {
                          "version": "v0.13.2",
                          "env_vars": {
                            "BARITO_CONSUL_URL": "http://consul.service.consul:8500",
                            "BARITO_KAFKA_BROKERS": "kafka.service.consul:9092",
                            "BARITO_KAFKA_GROUP_ID": "barito-group",
                            "BARITO_PUSH_METRIC_URL": "",
                            "BARITO_CONSUL_KAFKA_NAME": "kafka",
                            "BARITO_ELASTICSEARCH_URL": "http://elasticsearch.service.consul:9200",
                            "BARITO_KAFKA_TOPIC_SUFFIX": "_pb",
                            "BARITO_KAFKA_CONSUMER_TOPICS": "barito-log",
                            "BARITO_CONSUL_ELASTICSEARCH_NAME": "elasticsearch"
                          }
                        }
                      }
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
              },
              {
                "type": "kibana",
                "desired_num_replicas": 1,
                "min_available_replicas": 0,
                "definition": {
                  "container_type": "stateless",
                  "strategy": "RollingUpdate",
                  "allow_failure": "false",
                  "source": {
                    "mode": "pull",              # can be local or pull. default is pull.
                    "alias": "lxd-ubuntu-minimal-kibana-6.8.5-1",
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
                        "hosts": [],
                        "run_as_server": false
                      },
                      "kibana": {
                        "config": {
                          "message_format": "Warning: TPS exceeded on these apps: %s. Please ask app group owner to <a style='text-decoration: underline; color: yellow;' target='_blank' href='https://gopay-systems.pages.golabs.io/wiki/products/barito/user/troubleshooting.html#got-alert-tps-an-app-exceeded-on-kibana'>increase TPS</a>.",
                          "prometheus_url": "http://prometheus.barito.golabs.io:9090",
                          "server.basePath": "",
                          "elasticsearch.url": "http://elasticsearch.service.consul:9200"
                        },
                        "version": "6.8.5"
                      },
                      "run_list": [],
                      "kibana_exporter": {
                        "kibana_version": "6.8.5"
                      }
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
            ],
  options: {"kafka_partition": 1, "kafka_replication_factor": 1, "max_tps": 100}
)

ClusterTemplate.create!(
  name: "Log - Medium",
  manifests: [
                {
                  "type": "consul",
                  "desired_num_replicas": 3,
                  "min_available_replicas": 2,
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
                },
                {
                  "type": "zookeeper",
                  "desired_num_replicas": 3,
                  "min_available_replicas": 2,
                  "definition": {
                    "container_type": "stateless",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "resource": {
                      "cpu_limit": "0-2",
                      "mem_limit": "5GB"
                    },
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-zookeeper-3.4.12-3",
                      "remote": {
                        "name": "barito-registry"
                      },
                      "fingerprint": "",
                      "source_type": "image"                      
                    },
                    "bootstrappers": [{
                      "bootstrap_type": "chef-solo",
                      "bootstrap_attributes": {
                        "consul": {
                          "hosts": [

                          ],
                          "run_as_server": false
                        },
                        "run_list": [

                        ],
                        "zookeeper": {
                          "hosts": [
                            ""
                          ],
                          "my_id": ""
                        }
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
                },
                {
                  "type": "kafka",
                  "desired_num_replicas": 3,
                  "min_available_replicas": 2,
                  "definition": {
                    "container_type": "stateful",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-kafka-2.11-8",
                      "remote": {
                        "name": "barito-registry"
                      },
                      "fingerprint": "",
                      "source_type": "image"                      
                    },
                    "resource": {
                      "cpu_limit": "1-4",
                      "mem_limit": "10GB"
                    },
                    "bootstrappers": [{
                      "bootstrap_type": "chef-solo",
                      "bootstrap_attributes": {
                        "kafka": {
                          "kafka": {
                            "hosts": [],
                            "hosts_count": 1
                          },
                          "zookeeper": {
                            "hosts": []
                          },
                          "scala_version": "2.11",
                          "confluent_version": "5.3.0"
                        },
                        "consul": {
                          "hosts": [],
                          "run_as_server": false
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
                },
                {
                  "type": "elasticsearch",
                  "desired_num_replicas": 3,
                  "min_available_replicas": 2,
                  "definition": {
                    "container_type": "stateful",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-elasticsearch-6.8.5-1",
                      "remote": {
                        "name": "barito-registry"
                      },
                      "fingerprint": "",
                      "source_type": "image"                      
                    },
                    "resource": {
                      "cpu_limit": "1-4",
                      "mem_limit": "20GB"
                    },
                    "bootstrappers": [{
                      "bootstrap_type": "chef-solo",
                      "bootstrap_attributes": {
                        "consul": {
                          "hosts": [],
                          "run_as_server": false
                        },
                        "run_list": [],
                        "elasticsearch": {
                          "version": "6.8.5",
                          "memory_lock": false,
                          "node_master": true,
                          "cluster_name": "",
                          "allocated_memory": 12000000,
                          "max_allocated_memory": 16000000,
                          "minimum_master_nodes": 2,
                          "index_number_of_replicas": 1
                        }
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
                },
                {
                  "type": "barito-flow-producer",
                  "desired_num_replicas": 3,
                  "min_available_replicas": 2,
                  "definition": {
                    "container_type": "stateless",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-barito-flow-producer-0.13.2-2",
                      "remote": {
                        "name": "barito-registry"
                      },
                      "fingerprint": "",
                      "source_type": "image"                      
                    },
                    "resource": {
                      "cpu_limit": "1-4",
                      "mem_limit": "20GB"
                    },
                    "bootstrappers": [{
                      "bootstrap_type": "chef-solo",
                      "bootstrap_attributes": {
                        "consul": {
                          "hosts": [],
                          "run_as_server": false
                        },
                        "run_list": [],
                        "barito-flow": {
                          "producer": {
                            "version": "v0.13.2",
                            "env_vars": {
                              "BARITO_CONSUL_URL": "",
                              "BARITO_KAFKA_BROKERS": "kafka.service.consul:9092",
                              "BARITO_PRODUCER_GRPC": ":8080",
                              "BARITO_PRODUCER_REST": ":8085",
                              "BARITO_PRODUCER_ADDRESS": ":8081",
                              "BARITO_PRODUCER_MAX_TPS": 0,
                              "BARITO_CONSUL_KAFKA_NAME": "kafka",
                              "BARITO_PRODUCER_REST_API": "false",
                              "BARITO_KAFKA_TOPIC_SUFFIX": "_pb",
                              "BARITO_KAFKA_PRODUCER_TOPIC": "barito-log",
                              "BARITO_PRODUCER_RATE_LIMIT_RESET_INTERVAL": 10
                            }
                          }
                        }
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
                },
                {
                  "type": "barito-flow-consumer",
                  "desired_num_replicas": 5,
                  "min_available_replicas": 4,
                  "definition": {
                    "container_type": "stateless",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-barito-flow-consumer-0.13.2-2",
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
                          "hosts": [

                          ],
                          "config": {
                            "consul.json": {
                              "bind_addr": ""
                            }
                          },
                          "run_as_server": false
                        },
                        "run_list": [

                        ],
                        "barito-flow": {
                          "consumer": {
                            "version": "v0.13.2",
                            "env_vars": {
                              "BARITO_CONSUL_URL": "http://consul.service.consul:8500",
                              "BARITO_KAFKA_BROKERS": "kafka.service.consul:9092",
                              "BARITO_KAFKA_GROUP_ID": "barito-group",
                              "BARITO_PUSH_METRIC_URL": "",
                              "BARITO_CONSUL_KAFKA_NAME": "kafka",
                              "BARITO_ELASTICSEARCH_URL": "http://elasticsearch.service.consul:9200",
                              "BARITO_KAFKA_TOPIC_SUFFIX": "_pb",
                              "BARITO_KAFKA_CONSUMER_TOPICS": "barito-log",
                              "BARITO_CONSUL_ELASTICSEARCH_NAME": "elasticsearch"
                            }
                          }
                        }
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
                },
                {
                  "type": "kibana",
                  "desired_num_replicas": 1,
                  "min_available_replicas": 0,
                  "definition": {
                    "container_type": "stateless",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-kibana-6.8.5-1",
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
                          "hosts": [],
                          "run_as_server": false
                        },
                        "kibana": {
                          "config": {
                            "message_format": "Warning: TPS exceeded on these apps: %s. Please ask app group owner to <a style='text-decoration: underline; color: yellow;' target='_blank' href='https://gopay-systems.pages.golabs.io/wiki/products/barito/user/troubleshooting.html#got-alert-tps-an-app-exceeded-on-kibana'>increase TPS</a>.",
                            "prometheus_url": "http://prometheus.barito.golabs.io:9090",
                            "server.basePath": "",
                            "elasticsearch.url": "http://elasticsearch.service.consul:9200"
                          },
                          "version": "6.8.5"
                        },
                        "run_list": [],
                        "kibana_exporter": {
                          "kibana_version": "6.8.5"
                        }
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
              ],
  options: {"kafka_partition": 30, "kafka_replication_factor": 3, "max_tps": 500}
)

ClusterTemplate.create!(
  name: "Log - Large",
  manifests: [
                {
                  "type": "consul",
                  "desired_num_replicas": 3,
                  "min_available_replicas": 2,
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
                },
                {
                  "type": "zookeeper",
                  "desired_num_replicas": 3,
                  "definition": {
                    "container_type": "stateless",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "resource": {
                      "cpu_limit": "0-2",
                      "mem_limit": "5GB"
                    },
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-zookeeper-3.4.12-3",
                      "remote": {
                        "name": "barito-registry"
                      },
                      "fingerprint": "",
                      "source_type": "image"                      
                    },
                    "bootstrappers": [{
                      "bootstrap_type": "chef-solo",
                      "bootstrap_attributes": {
                        "consul": {
                          "hosts": [

                          ],
                          "run_as_server": false
                        },
                        "run_list": [

                        ],
                        "zookeeper": {
                          "hosts": [
                            ""
                          ],
                          "my_id": ""
                        }
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
                },
                {
                  "type": "kafka",
                  "desired_num_replicas": 3,
                  "min_available_replicas": 2,
                  "definition": {
                    "container_type": "stateful",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-kafka-2.11-8",
                      "remote": {
                        "name": "barito-registry"
                      },
                      "fingerprint": "",
                      "source_type": "image"                      
                    },
                    "resource": {
                      "cpu_limit": "1-4",
                      "mem_limit": "10GB"
                    },
                    "bootstrappers": [{
                      "bootstrap_type": "chef-solo",
                      "bootstrap_attributes": {
                        "kafka": {
                          "kafka": {
                            "hosts": [],
                            "hosts_count": 1
                          },
                          "zookeeper": {
                            "hosts": []
                          },
                          "scala_version": "2.11",
                          "confluent_version": "5.3.0"
                        },
                        "consul": {
                          "hosts": [],
                          "run_as_server": false
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
                },
                {
                  "type": "elasticsearch",
                  "desired_num_replicas": 3,
                  "min_available_replicas": 2,
                  "definition": {
                    "container_type": "stateful",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-elasticsearch-6.8.5-1",
                      "remote": {
                        "name": "barito-registry"
                      },
                      "fingerprint": "",
                      "source_type": "image"                      
                    },
                    "resource": {
                      "cpu_limit": "1-4",
                      "mem_limit": "20GB"
                    },
                    "bootstrappers": [{
                      "bootstrap_type": "chef-solo",
                      "bootstrap_attributes": {
                        "consul": {
                          "hosts": [],
                          "run_as_server": false
                        },
                        "run_list": [],
                        "elasticsearch": {
                          "version": "6.8.5",
                          "memory_lock": false,
                          "node_master": true,
                          "cluster_name": "",
                          "allocated_memory": 12000000,
                          "max_allocated_memory": 16000000,
                          "minimum_master_nodes": 2,
                          "index_number_of_replicas": 1
                        }
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
                },
                {
                  "type": "barito-flow-producer",
                  "desired_num_replicas": 3,
                  "min_available_replicas": 2,
                  "definition": {
                    "container_type": "stateless",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-barito-flow-producer-0.13.2-2",
                      "remote": {
                        "name": "barito-registry"
                      },
                      "fingerprint": "",
                      "source_type": "image"                      
                    },
                    "resource": {
                      "cpu_limit": "1-4",
                      "mem_limit": "20GB"
                    },
                    "bootstrappers": [{
                      "bootstrap_type": "chef-solo",
                      "bootstrap_attributes": {
                        "consul": {
                          "hosts": [],
                          "run_as_server": false
                        },
                        "run_list": [],
                        "barito-flow": {
                          "producer": {
                            "version": "v0.13.2",
                            "env_vars": {
                              "BARITO_CONSUL_URL": "",
                              "BARITO_KAFKA_BROKERS": "kafka.service.consul:9092",
                              "BARITO_PRODUCER_GRPC": ":8080",
                              "BARITO_PRODUCER_REST": ":8085",
                              "BARITO_PRODUCER_ADDRESS": ":8081",
                              "BARITO_PRODUCER_MAX_TPS": 0,
                              "BARITO_CONSUL_KAFKA_NAME": "kafka",
                              "BARITO_PRODUCER_REST_API": "false",
                              "BARITO_KAFKA_TOPIC_SUFFIX": "_pb",
                              "BARITO_KAFKA_PRODUCER_TOPIC": "barito-log",
                              "BARITO_PRODUCER_RATE_LIMIT_RESET_INTERVAL": 10
                            }
                          }
                        }
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
                },
                {
                  "type": "barito-flow-consumer",
                  "desired_num_replicas": 10,
                  "min_available_replicas": 9,
                  "definition": {
                    "container_type": "stateless",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-barito-flow-consumer-0.13.2-2",
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
                          "hosts": [

                          ],
                          "config": {
                            "consul.json": {
                              "bind_addr": ""
                            }
                          },
                          "run_as_server": false
                        },
                        "run_list": [

                        ],
                        "barito-flow": {
                          "consumer": {
                            "version": "v0.13.2",
                            "env_vars": {
                              "BARITO_CONSUL_URL": "http://consul.service.consul:8500",
                              "BARITO_KAFKA_BROKERS": "kafka.service.consul:9092",
                              "BARITO_KAFKA_GROUP_ID": "barito-group",
                              "BARITO_PUSH_METRIC_URL": "",
                              "BARITO_CONSUL_KAFKA_NAME": "kafka",
                              "BARITO_ELASTICSEARCH_URL": "http://elasticsearch.service.consul:9200",
                              "BARITO_KAFKA_TOPIC_SUFFIX": "_pb",
                              "BARITO_KAFKA_CONSUMER_TOPICS": "barito-log",
                              "BARITO_CONSUL_ELASTICSEARCH_NAME": "elasticsearch"
                            }
                          }
                        }
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
                },
                {
                  "type": "kibana",
                  "desired_num_replicas": 1,
                  "min_available_replicas": 0,
                  "definition": {
                    "container_type": "stateless",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-kibana-6.8.5-1",
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
                          "hosts": [],
                          "run_as_server": false
                        },
                        "kibana": {
                          "config": {
                            "message_format": "Warning: TPS exceeded on these apps: %s. Please ask app group owner to <a style='text-decoration: underline; color: yellow;' target='_blank' href='https://gopay-systems.pages.golabs.io/wiki/products/barito/user/troubleshooting.html#got-alert-tps-an-app-exceeded-on-kibana'>increase TPS</a>.",
                            "prometheus_url": "http://prometheus.barito.golabs.io:9090",
                            "server.basePath": "",
                            "elasticsearch.url": "http://elasticsearch.service.consul:9200"
                          },
                          "version": "6.8.5"
                        },
                        "run_list": [],
                        "kibana_exporter": {
                          "kibana_version": "6.8.5"
                        }
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
              ],
  options: {"kafka_partition": 50, "kafka_replication_factor": 3, "max_tps": 1000}
)
