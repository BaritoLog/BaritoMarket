json.extract! service_config, :id, :ip_address, :config_json, :created_at, :updated_at
json.url service_config_url(service_config, format: :json)
