json.extract! forwarder, :id, :name, :host, :group_id, :store_id, :kafka_broker_hosts, :zookeeper_hosts, :kafka_topics, :heartbeat_url, :created_at, :updated_at
json.url forwarder_url(forwarder, format: :json)
