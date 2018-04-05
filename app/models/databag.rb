class Databag < ActiveRecord::Base
  acts_as_paranoid
  validates_presence_of :ip_address, :data, :tags
end
