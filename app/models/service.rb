class Service < ActiveRecord::Base
  validates_presence_of :name, :group_id, :store_id

  belongs_to :group, required: true
  belongs_to :store, required: true
  belongs_to :forwarder, required: true

end
