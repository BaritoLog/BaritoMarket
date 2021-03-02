class HelmInfrastructurePolicy < ApplicationPolicy
  def show?
    barito_superadmin?
  end

  def new?
    show?
  end

  def create?
    show?
  end

  def edit?
    show?
  end

  def synchronize?
    show?
  end

  def update?
    show?
  end
end
