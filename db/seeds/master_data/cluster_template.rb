
# Fetch dependency
# -----------------------------------------------------------------------------

# Seeds
# -----------------------------------------------------------------------------

### Staging
ClusterTemplate.create!(
  name: "Small",
  instances: [
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
  ],
  kafka_options: {"partition": 1, "replication_factor": 1}
)

ClusterTemplate.create!(
  name: "Medium",
  instances: [
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
      "count": 3
    },
    {
      "name": "kafka",
      "count": 3
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
      "count": 5
    },
    {
      "name": "kibana",
      "count": 1
    }
  ],
  kafka_options: {"partition": 5, "replication_factor": 3}
)

ClusterTemplate.create!(
  name: "Large",
  instances: [
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
      "count": 3
    },
    {
      "name": "kafka",
      "count": 5
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
      "count": 7
    },
    {
      "name": "kibana",
      "count": 1
    }
  ],
  kafka_options: {"partition": 7, "replication_factor": 3}
)

### Production
ClusterTemplate.create!(
  env: "production",
  name: "Production - Small",
  max_tps: 100,
  instances: [
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
  ],
  kafka_options: {"partition": 1, "replication_factor": 1}
)

ClusterTemplate.create!(
  env: "production",
  name: "Production - Medium",
  max_tps: 500,
  instances: [
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
      "count": 3
    },
    {
      "name": "kafka",
      "count": 3
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
      "count": 5
    },
    {
      "name": "kibana",
      "count": 1
    }
  ],
  kafka_options: {"partition": 5, "replication_factor": 3}
)

ClusterTemplate.create!(
  env: "production",
  name: "Production - Large",
  max_tps: 1000,
  instances: [
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
      "count": 3
    },
    {
      "name": "kafka",
      "count": 5
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
      "count": 7
    },
    {
      "name": "kibana",
      "count": 1
    }
  ],
  kafka_options: {"partition": 7, "replication_factor": 3}
)
