class GroupUsersPolicy < ApplicationPolicy
  def create?
    barito_superadmin? || user.can_access_user_group?(record, roles: %i(owner))
  end

  def set_role?
    create?
  end

  def destroy?
    barito_superadmin?
  end
end
