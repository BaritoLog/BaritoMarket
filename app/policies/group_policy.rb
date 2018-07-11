class GroupPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    index?
  end

  def new?
    user.admin?
  end

  def create?
    new?
  end

  def destroy?
    index?
  end
end
