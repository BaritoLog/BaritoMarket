class AppGroupPolicy < ApplicationPolicy
  def new?
    return true if get_user_groups
    false
  end

  def create?
    new?
  end

  def show?
    return true if get_user_groups

    app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
    app_group_ids.include?(record.id)
  end

  def manage_access?
    return true if get_user_groups

    AppGroupUser.
      joins(:role).
      where(user: user, app_group_roles: { name: [:owner] }).count > 0
  end

  def allow_see_apps?
    return true if get_user_groups

    user.app_groups.where(id: record.id).count > 0
  end

  class Scope < Scope
    def resolve
      if Figaro.env.enable_cas_integration == 'true'
        gate_groups = GateWrapper.new(user).check_user_groups.symbolize_keys[:groups] || []
        return scope.all if Group.where(name: gate_groups).count > 0
      end

      app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
      scope.where(id: app_group_ids)
    end
  end
end
