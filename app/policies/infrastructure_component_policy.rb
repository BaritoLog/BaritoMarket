class InfrastructureComponentPolicy < ApplicationPolicy
  def index?
    barito_superadmin?
  end

  def edit?
    index?
  end

  def update?
    edit?
  end
end
