class ClientGroup < ActiveRecord::Base
    acts_as_paranoid
    belongs_to :user_group
    belongs_to :client
end
  