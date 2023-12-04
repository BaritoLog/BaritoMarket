class UserPolicy < ApplicationPolicy
  def index?
    barito_superadmin? || user.can_access_user_group?(record, roles: %i(owner admin member))
  end
end