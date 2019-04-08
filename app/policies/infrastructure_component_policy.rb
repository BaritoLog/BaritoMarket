class InfrastructureComponentPolicy < ApplicationPolicy
  def edit?
    return true if is_barito_superadmin?
    false
  end

  def update?
    edit?
  end
end
