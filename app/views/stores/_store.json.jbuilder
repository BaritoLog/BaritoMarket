json.extract! store, :id, :name, :elasticsearch_host, :kibana_host, :created_at, :updated_at
json.url store_url(store, format: :json)
