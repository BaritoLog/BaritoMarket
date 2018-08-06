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
