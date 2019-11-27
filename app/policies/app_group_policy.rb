class AppGroupPolicy < ApplicationPolicy
  def show?
    return true if barito_superadmin?
    user.can_access_app_group? record
  end

  def new?
    return true if barito_superadmin?
    false
  end

  def create?
    new?
  end

  def update?
    return true if barito_superadmin?
    user.can_access_app_group? record, roles: %i(owner admin)
  end

  def manage_access?
    return true if barito_superadmin?
    user.can_access_app_group? record, roles: %i(owner)
  end

  def see_app_groups?
    return true if barito_superadmin?
    user.can_access_app_group? record
  end

  def set_status?
    return true if barito_superadmin?
    user.can_access_app_group? record, roles: %i(owner)
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
