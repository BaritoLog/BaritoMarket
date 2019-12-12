class ComponentTemplatePolicy < ApplicationPolicy
  def index?
    barito_superadmin?
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
