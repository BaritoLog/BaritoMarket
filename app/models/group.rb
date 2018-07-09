class Group < ActiveRecord::Base
  validates :name, presence: true
end
