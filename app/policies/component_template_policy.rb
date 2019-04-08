class ComponentTemplatePolicy < ApplicationPolicy
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

  def edit?
    index?
  end

  def update?
    index?
  end

  def create?
    index?
  end

  def destroy?
    index?
  end
end
