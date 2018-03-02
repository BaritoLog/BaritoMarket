json.extract! stream, :id, :id, :name, :receiver_host, :zookeeper_hosts, :kafka_broker_hosts, :receiver_heartbeat_url, :kafka_manager_host, :created_at, :updated_at
json.url stream_url(stream, format: :json)
