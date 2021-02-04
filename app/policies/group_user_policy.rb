class GroupUserPolicy < ApplicationPolicy
  def create?
    barito_superadmin? || user.can_access_user_group?(record.group, roles: %i(owner))
  end

  def set_role?
    create?
  end

  def destroy?
    create?
  end
end
