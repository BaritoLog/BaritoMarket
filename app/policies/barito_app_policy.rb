class BaritoAppPolicy < ApplicationPolicy
  def create?
    return true if get_user_groups
    return false if record.app_group.nil?
    record.app_group.app_group_users.
      joins(:role).
      where(user: user, app_group_roles: { name: %i(admin owner) }).
      count.positive?
  end

  def delete?
    create?
  end

  def destroy?
    create?
  end

  def toggle_status?
    create?
  end
end
