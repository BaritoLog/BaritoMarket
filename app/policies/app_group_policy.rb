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

  class Scope < Scope
    def resolve
      if Figaro.env.enable_cas_integration == 'true'
        gate_groups = GateClient.
          new(user).
          check_user_groups.
          symbolize_keys[:groups] || []
        return scope.active if gate_groups.include?("barito-superadmin") or gate_groups.include?("global-viewer")
      else
        user_groups = []
        user.groups.each do |group|
          user_groups << group.name
        end
        return scope.active if user_groups.include?("barito-superadmin") or user_groups.include?("global-viewer")
      end

      app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
      scope.active.where(id: app_group_ids)
    end
  end
end
