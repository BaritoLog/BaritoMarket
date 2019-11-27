class User < ApplicationRecord
  after_create :add_global_viewer_group, if: :is_global_viewer?

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

  def self.find_by_username_or_email(input)
    User.where("username = :input OR email = :input", input: input).first
  end

  def add_global_viewer_group
    group = Group.find_by(name: Figaro.env.global_viewer_role)
    group_user = GroupUser.create(
      group_id: group.id,
      user_id: self.id
    )
  end

  def is_global_viewer?
    return true if Figaro.env.global_viewer == "true"
  end

  def can_access_app_group?(app_group, roles: nil)
    memberships = augment_with_role_checking(app_group_users.where(app_group: app_group), roles)
    return true if memberships.exists?

    memberships = augment_with_role_checking(group_users.joins(
      group: :app_group_teams).where(groups: { app_group_teams: { app_group: app_group }}), roles)
    memberships.exists?
  end

  private

  def augment_with_role_checking(query, roles)
    return query.joins(:role).where(app_group_roles: { name: roles }) if roles
    query
  end
end
