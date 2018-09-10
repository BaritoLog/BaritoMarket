class User < ApplicationRecord
  if Figaro.env.enable_cas_integration == 'true'
    devise :cas_authenticatable, :trackable
  else
    devise :database_authenticatable, :trackable, :registerable
  end

  has_one :app_group_user
  has_many :app_groups, through: :app_group_user
  has_many :group_users
  has_many :groups, through: :group_users

  validates :username, uniqueness: true, allow_blank: true
  validates :email, uniqueness: true, allow_blank: true

  def display_name
    return username if email.blank?
    email
  end

  def self.find_by_username_or_email(input)
    User.where("username = :input OR email = :input", input: input).first
  end
end
