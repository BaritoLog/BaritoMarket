class InfrastructureComponentPolicy < ApplicationPolicy
  def index?
    return true if is_barito_superadmin?
    false
  end
  
  def edit?
    index?
  end

  def update?
    edit?
  end
end
