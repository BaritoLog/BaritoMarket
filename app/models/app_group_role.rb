class AppGroupRole < ApplicationRecord
  has_many :app_group_users

  validates :name, presence: true

  #
  # Roles
  #

  def self.as_member
    find_by(name: 'member')
  end
end
