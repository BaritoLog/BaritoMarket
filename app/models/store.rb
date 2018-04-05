class Store < ActiveRecord::Base
  acts_as_paranoid
  validates_presence_of :name, :elasticsearch_host, :kibana_host
end
