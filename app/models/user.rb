class User < ApplicationRecord
  if Figaro.env.enable_cas_integration == 'true'
    devise :cas_authenticatable, :trackable
  else
    devise :database_authenticatable, :trackable, :registerable
  end

  has_many :app_group_users
  has_many :app_groups, through: :app_group_users
  has_many :group_users
  has_many :groups, through: :group_users

  validates :username, uniqueness: true, allow_blank: true
  validates :email, uniqueness: true, allow_blank: true

  def display_name
    return username if email.blank?
    email
  end
end
