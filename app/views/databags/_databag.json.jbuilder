json.extract! databag, :id, :ip_address, :config_json, :tags, :created_at, :updated_at
json.url databag_url(databag, format: :json)
