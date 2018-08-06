class GroupPolicy < ApplicationPolicy
  def index?
    return true if get_user_groups
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
