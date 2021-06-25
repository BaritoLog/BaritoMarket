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

  def exists?
    barito_superadmin? || user.can_access_app_group?(record.app_group)
  end

  def delete?
    show?
  end
end
