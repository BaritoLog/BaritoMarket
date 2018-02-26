class Store < ActiveRecord::Base
  validates_presence_of :name, :elasticsearch_host, :kibana_host
end
