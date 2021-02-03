class GroupPolicy < ApplicationPolicy
  def index?
    barito_superadmin? || user.can_access_user_group?(record, roles: %i(owner admin))
  end

  def show?
    index?
  end

  def new?
    barito_superadmin?
  end

  def create?
    barito_superadmin?
  end

  def destroy?
    barito_superadmin?
  end

  def see_user_groups?
    barito_superadmin? || user.can_access_user_group?(record)
  end
end
