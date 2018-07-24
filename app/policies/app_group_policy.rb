class AppGroupPolicy < ApplicationPolicy
  def show?
    return true if get_user_groups
    return true if record.created_by == user

    app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
    app_group_ids.include?(record.id)
  end

  def manage_access?
    return true if get_user_groups
    return true if record.created_by == user

    AppGroupUser.
      joins(:role).
      where(user: user, app_group_roles: { name: [:owner] }).count > 0
  end

  def allow_action?
    manage_access?
  end

  def allow_upgrade?
    return true if get_user_groups
    return true if record.created_by == user

    AppGroupUser.
      joins(:role).
      where(user: user, app_group_roles: { name: [:admin, :owner] }).
      count > 0
  end

  class Scope < Scope
    def resolve
      if Figaro.env.enable_cas_integration == 'true'
        gate_groups = GateWrapper.new(user).check_user_groups.symbolize_keys[:groups] || []
        return scope.all if Group.where(name: gate_groups).count > 0
      end

      app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
      scope.where(created_by: user).
        or(scope.where(id: app_group_ids))
    end
  end

  private

  def get_user_groups
    if Figaro.env.enable_cas_integration == 'true'
      gate_groups = GateWrapper.new(user).check_user_groups.symbolize_keys[:groups] || []
      return true if Group.where(name: gate_groups).count > 0
    else
      return true if user.groups.count > 0
    end
  end
end
