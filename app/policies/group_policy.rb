class GroupPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    index?
  end

  def create?
    index?
  end

  def destroy?
    index?
  end
end
