class ServiceConfig < ActiveRecord::Base
  validates_presence_of :ip_address, :config_json, :tags
end
