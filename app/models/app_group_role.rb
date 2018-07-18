class AppGroupRole < ApplicationRecord
  has_many :app_group_users

  validates :name, presence: true

  #
  # Roles
  #

  def self.as_member
    find_by(name: 'member')
  end

  #
  # List of access
  #

  def self.allow_upgrade
    [:admin, :owner]
  end

  def self.allow_manage_access
    [:owner]
  end

  def self.allow_add_apps
    allow_upgrade
  end
end
