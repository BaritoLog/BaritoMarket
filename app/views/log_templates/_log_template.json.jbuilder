json.extract! log_template, :id, :name, :tps_limit, :zookeeper_instances, :kafka_instances, :es_instances, :consul_instances, :yggdrasil_instances, :kibana_instances, :created_at, :updated_at
json.url log_template_url(log_template, format: :json)
