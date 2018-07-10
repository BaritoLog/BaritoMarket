class AppGroupPolicy < ApplicationPolicy
  def show?
    return true if user.admin? || record.created_by == user

    if Figaro.env.enable_check_gate == 'true'
      gate_groups = GateWrapper.new(user).check_user_groups['groups'] || []
      groups = AppGroupPermission.joins(:group).where('groups.name IN (?)', gate_groups)
      app_group_ids = groups.pluck(:app_group_id)
    else
      group_ids = user.groups.pluck(:id)
      app_group_ids = AppGroupPermission.where(group_id: group_ids)
    end

    record.class.where(created_by: user).or(record.class.where(id: app_group_ids)).count > 0
  end

  def manage_access?
    return true if user.admin? || record.created_by == user

    AppGroupAdmin.where(app_group: record, user: user).count > 0
  end

  def allow_action?
    return true if user.admin? || record.created_by == user

    AppGroupAdmin.where(user: user, app_group: record).count > 0
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      if Figaro.env.enable_check_gate == 'true'
        gate_groups = GateWrapper.new(user).check_user_groups['groups'] || []
        groups = AppGroupPermission.joins(:group).where('groups.name IN (?)', gate_groups)
        scope.where(created_by: user).or(scope.where(id: groups.pluck(:app_group_id)))
      else
        group_ids = user.groups.pluck(:id)
        app_group_ids = AppGroupPermission.where(group_id: group_ids)
        scope.where(created_by: user).or(scope.where(id: app_group_ids))
      end
    end
  end
end
