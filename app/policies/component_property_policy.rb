class ComponentPropertyPolicy < ApplicationPolicy
  def index?
    return true if is_barito_superadmin?
    false
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
