class GroupPolicy < ApplicationPolicy
  def index?
    if Figaro.env.enable_cas_integration == 'true'
      gate_groups = GateWrapper.new(user).check_user_groups.symbolize_keys[:groups] || []
      return Group.all if Group.where(name: gate_groups).count > 0
    else
      return true if user.groups.count > 0
    end
  end

  def show?
    index?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def destroy?
    index?
  end
end
