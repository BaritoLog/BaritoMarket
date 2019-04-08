
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
  options: {"kafka_partition": 1, "kafka_replication_factor": 1, "max_tps": 100}
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
  options: {"kafka_partition": 5, "kafka_replication_factor": 3, "max_tps": 500}
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
      "count": 10
    },
    {
      "name": "kibana",
      "count": 1
    }
  ],
  options: {"kafka_partition": 30, "kafka_replication_factor": 3, "max_tps": 1000}
)
