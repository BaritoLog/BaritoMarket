
# Fetch dependency
# -----------------------------------------------------------------------------

# Seeds
# -----------------------------------------------------------------------------

### Staging
ComponentTemplate.create!(
  env: "staging",
  name: "Staging - Small",
  max_tps: 100,
  instances: {
    "yggdrasil": {"count": 0, "seq": 0}, 
    "consul": {"count": 1, "seq": 1}, 
    "zookeeper": {"count": 1, "seq": 2}, 
    "kafka": {"count": 1, "seq": 3}, 
    "elasticsearch": {"count": 1, "seq": 4}, 
    "barito-flow-producer": {"count": 1, "seq": 5}, 
    "barito-flow-consumer": {"count": 1, "seq": 6}, 
    "kibana": {"count": 1, "seq": 7}
  },
  kafka_options: {"partition": 1, "replication_factor": 1}
)

ComponentTemplate.create!(
  env: "staging",
  name: "Staging - Medium",
  max_tps: 500,
  instances: {
    "yggdrasil": {"count": 0, "seq": 0}, 
    "consul": {"count": 1, "seq": 1}, 
    "zookeeper": {"count": 3, "seq": 2}, 
    "kafka": {"count": 3, "seq": 3}, 
    "elasticsearch": {"count": 1, "seq": 4}, 
    "barito-flow-producer": {"count": 1, "seq": 5}, 
    "barito-flow-consumer": {"count": 5, "seq": 6}, 
    "kibana": {"count": 1, "seq": 7}
  },
  kafka_options: {"partition": 5, "replication_factor": 3}
)

ComponentTemplate.create!(
  env: "staging",
  name: "Staging - Large",
  max_tps: 1000,
  instances: {
    "yggdrasil": {"count": 0, "seq": 0}, 
    "consul": {"count": 1, "seq": 1}, 
    "zookeeper": {"count": 3, "seq": 2}, 
    "kafka": {"count": 5, "seq": 3}, 
    "elasticsearch": {"count": 1, "seq": 4}, 
    "barito-flow-producer": {"count": 1, "seq": 5}, 
    "barito-flow-consumer": {"count": 7, "seq": 6}, 
    "kibana": {"count": 1, "seq": 7}
  },
  kafka_options: {"partition": 7, "replication_factor": 3}
)

### Production
ComponentTemplate.create!(
  env: "production",
  name: "Production - Small",
  max_tps: 100,
  instances: {
    "yggdrasil": {"count": 0, "seq": 0}, 
    "consul": {"count": 1, "seq": 1}, 
    "zookeeper": {"count": 1, "seq": 2}, 
    "kafka": {"count": 1, "seq": 3}, 
    "elasticsearch": {"count": 1, "seq": 4}, 
    "barito-flow-producer": {"count": 1, "seq": 5}, 
    "barito-flow-consumer": {"count": 1, "seq": 6}, 
    "kibana": {"count": 1, "seq": 7}
  },
  kafka_options: {"partition": 1, "replication_factor": 1}
)

ComponentTemplate.create!(
  env: "production",
  name: "Production - Medium",
  max_tps: 500,
  instances: {
    "yggdrasil": {"count": 0, "seq": 0}, 
    "consul": {"count": 1, "seq": 1}, 
    "zookeeper": {"count": 3, "seq": 2}, 
    "kafka": {"count": 3, "seq": 3}, 
    "elasticsearch": {"count": 1, "seq": 4}, 
    "barito-flow-producer": {"count": 1, "seq": 5}, 
    "barito-flow-consumer": {"count": 5, "seq": 6}, 
    "kibana": {"count": 1, "seq": 7}
  },
  kafka_options: {"partition": 5, "replication_factor": 3}
)

ComponentTemplate.create!(
  env: "production",
  name: "Production - Large",
  max_tps: 1000,
  instances: {
    "yggdrasil": {"count": 0, "seq": 0}, 
    "consul": {"count": 1, "seq": 1}, 
    "zookeeper": {"count": 3, "seq": 2}, 
    "kafka": {"count": 5, "seq": 3}, 
    "elasticsearch": {"count": 1, "seq": 4}, 
    "barito-flow-producer": {"count": 1, "seq": 5}, 
    "barito-flow-consumer": {"count": 7, "seq": 6}, 
    "kibana": {"count": 1, "seq": 7}
  },
  kafka_options: {"partition": 7, "replication_factor": 3}
)
