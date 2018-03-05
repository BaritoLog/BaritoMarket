json.extract! service, :id, :name, :description, :stream_id, :store_id, :forwarder_id, :produce_url, :kibana_host, :kafka_topics, :kafka_topic_partition, :heartbeat_url, :created_at, :updated_at
json.url service_url(service, format: :json)
