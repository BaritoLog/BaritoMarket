class AppGroupPolicy < ApplicationPolicy
  def show?
    return true if is_barito_superadmin?
    app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
    app_group_ids.include?(record.id)
  end

  def new?
    return true if is_barito_superadmin?
    false
  end

  def create?
    new?
  end

  def update?
    return true if is_barito_superadmin?
    record.app_group_users.
      joins(:role).
      where(user: user, app_group_roles: { name: %i(owner admin) }).
      count.positive?
  end

  def manage_access?
    return true if is_barito_superadmin?
    record.app_group_users.
      joins(:role).
      where(user: user, app_group_roles: { name: [:owner] }).
      count.positive?
  end

  def see_app_groups?
    return true if is_barito_superadmin?
    app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
    app_group_ids.include?(record.id)
  end

  def set_status?
    return true if is_barito_superadmin?
    role_id = AppGroupRole.find_by(name: 'owner')
    AppGroupUser.find_by(user_id: user.id, app_group_id: record.id, role_id: role_id)
  end

  class Scope < Scope
    def resolve
      if Figaro.env.global_viewer == 'true'
        return scope.active if get_merge_groups(user).include?('barito-superadmin') || get_merge_groups(user).include?(Figaro.env.global_viewer_role)
      else
        return scope.active if get_gate_groups(user).include?('barito-superadmin') || get_user_groups(user).include?('barito-superadmin')
      end

      app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
      scope.active.where(id: app_group_ids)
    end

    def get_gate_groups(user)
      gate_groups = []
      if Figaro.env.enable_cas_integration == 'true'
        gate_groups = GateClient.new(user).check_user_groups.symbolize_keys[:groups]
      end
      gate_groups
    end

    def get_user_groups(user)
      user_groups = []
      user.groups.each do |group|
        user_groups << group.name
      end
      user_groups
    end

    def get_merge_groups(user)
      (get_gate_groups(user) + get_user_groups(user)).uniq
    end
  end
end
