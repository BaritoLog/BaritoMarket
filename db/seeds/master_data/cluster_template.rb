
# Fetch dependency
# -----------------------------------------------------------------------------

# Seeds
# -----------------------------------------------------------------------------

### Staging
ClusterTemplate.create!(
  name: "Log - Small",
  instances: [
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
  ],
  options: {"kafka_partition": 1, "kafka_replication_factor": 1, "max_tps": 100}
)

ClusterTemplate.create!(
  name: "Log - Medium",
  instances: [
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
      "count": 3
    },
    {
      "type": "kafka",
      "count": 3
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
      "count": 5
    },
    {
      "type": "kibana",
      "count": 1
    }
  ],
  options: {"kafka_partition": 5, "kafka_replication_factor": 3, "max_tps": 500}
)

ClusterTemplate.create!(
  name: "Log - Large",
  instances: [
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
      "count": 3
    },
    {
      "type": "kafka",
      "count": 5
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
      "count": 10
    },
    {
      "type": "kibana",
      "count": 1
    }
  ],
  options: {"kafka_partition": 30, "kafka_replication_factor": 3, "max_tps": 1000}
)
