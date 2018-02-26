json.extract! service, :id, :name, :description, :group_id, :store_id, :produce_url, :kibana_host, :kafka_topics, :kafka_topic_partition, :heartbeat_url, :created_at, :updated_at
json.url service_url(service, format: :json)
