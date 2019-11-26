class InfrastructureComponentPolicy < ApplicationPolicy
  def index?
    return true if barito_superadmin?
    false
  end

  def edit?
    index?
  end

  def update?
    edit?
  end
end
