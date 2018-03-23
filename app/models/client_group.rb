class ClientGroup < ActiveRecord::Base
    belongs_to :user_group
    belongs_to :client
end
  