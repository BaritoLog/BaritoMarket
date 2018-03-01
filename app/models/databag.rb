class Databag < ActiveRecord::Base
  validates_presence_of :ip_address, :data, :tags
end
