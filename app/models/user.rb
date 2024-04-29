class User < ApplicationRecord
  after_create :add_global_viewer_group, if: :is_global_viewer?

  if Figaro.env.enable_sso_integration == "true"
    devise :trackable, :omniauthable, omniauth_providers: %i[google_oauth2]
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

  # find user by email 
  #   if not exists, find by it's username then bind the email
  #   if no username match, create the user
  def self.find_or_create_by_email(email)
    user = User.where(email: email).first

    if user.nil?
      username_from_email = email.split('@').first
      user = User.where(username: username_from_email).first
      unless user.nil?
        user.update_attribute(:email, email)
      else
        user = User.create(username: username_from_email, email: email)
      end
    end

    user
  end

  def self.valid_email_domain? email
    domain = email.split('@').last
    hosted_domains = Figaro.env.whitelisted_email_domains.to_s.split(',')
    hosted_domains.include?(domain)
  end

  def add_global_viewer_group
    group = Group.find_by(name: Figaro.env.global_viewer_role)
    group_role = AppGroupRole.find_by_name('member')
    group_user = GroupUser.create(
      group_id: group.id,
      user_id: self.id,
      role_id: group_role.id
    )
  end

  def is_global_viewer?
    return true if Figaro.env.global_viewer == "true"
  end

  def can_access_app_group?(app_group, roles: nil)
    filter_accessible_app_groups(AppGroup.where(id: app_group.id), roles: roles).exists?
  end

  def filter_accessible_app_groups(app_groups, roles: nil)

    app_group_ids = app_groups.pluck(:id)

    group_ids = AppGroupTeam.where(app_group_id: app_group_ids).pluck(:group_id)

    group_having_expiration_date = GroupUser.where(group_id: group_ids, user_id: self.id).where.not(expiration_date:nil).pluck(:group_id)

    group_not_having_expiration_date = GroupUser.where(group_id: group_ids, user_id: self.id, expiration_date:nil).pluck(:group_id)

    app_group_having_group_expiration_date = AppGroupTeam.where(group_id: group_having_expiration_date).pluck(:app_group_id)

    app_group_not_having_group_expiration_date = AppGroupTeam.where(group_id: group_not_having_expiration_date).pluck(:app_group_id)

    where_clause_no_expiration = {
      user: self,
      role: (AppGroupRole.where(name: roles).pluck(:id) if roles)
    }.compact

    where_clause_with_expiration = {
      user: self,
      role: (AppGroupRole.where(name: roles).pluck(:id) if roles),
      expiration_date: Time.now..Float::INFINITY
    }.compact

    app_group_having_expiration_date = AppGroupUser.where(app_group_id: app_group_ids, user_id: self.id).where.not(expiration_date:nil).pluck(:app_group_id)

    app_group_not_having_expiration_date = AppGroupUser.where(app_group_id: app_group_ids, user_id: self.id, expiration_date:nil).pluck(:app_group_id)

    augmented_app_groups = app_groups.left_outer_joins(:app_group_users, groups: :group_users)

    augmented_app_groups.where(id: app_group_not_having_expiration_date, app_group_users: where_clause_no_expiration).
    or(augmented_app_groups.where(id: app_group_having_expiration_date, app_group_users: where_clause_with_expiration)).
    or(augmented_app_groups.where(id: app_group_having_group_expiration_date, app_group_teams: { groups: { group_users: where_clause_with_expiration }})).
    or(augmented_app_groups.where(id: app_group_not_having_group_expiration_date, app_group_teams: { groups: { group_users: where_clause_no_expiration }}))
  end

  def can_access_user_group?(user_group, roles: nil)
    if defined?(user_group.ids)
      ids = user_group.ids
      for id in ids
        return true if filter_accessible_user_groups(Group.where(id: id), roles: roles).exists?
      end
      return false
    else
      id = user_group.id
      filter_accessible_user_groups(Group.where(id: id), roles: roles).exists?
    end
  end

  def filter_accessible_user_groups(user_group, roles: nil)
    where_clause = {
      user: self,
      role: (AppGroupRole.where(name: roles).pluck(:id) if roles)
    }.compact
    
    augmented_user_groups = user_group.left_outer_joins(:group_users)
    augmented_user_groups.where(group_users: where_clause)
  end
end
