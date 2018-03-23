json.extract! service, :id, :name, :description, :client_group_id, :stream_id, :store_id, :forwarder_id, :application_secret, :produce_url, :kibana_host, :kafka_topics, :kafka_topic_partition, :heartbeat_url, :created_at, :updated_at
json.url service_url(service, format: :json)
