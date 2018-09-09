class AppGroupRole < ApplicationRecord
  has_many :app_group_users

  validates :name, presence: true
end
