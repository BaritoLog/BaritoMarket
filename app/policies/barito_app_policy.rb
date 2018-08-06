class BaritoAppPolicy < ApplicationPolicy
  def create?
    return true if get_user_groups

    AppGroupUser.
      joins(:role).
      where(user: user, app_group_roles: { name: [:admin, :owner] }).
      count > 0
  end

  def delete?
    create?
  end
end
