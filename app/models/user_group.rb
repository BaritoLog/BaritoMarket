class UserGroup < ActiveRecord::Base
    validates_presence_of :name

    has_many :client_groups
    has_many :clients, through: :client_groups
end
  