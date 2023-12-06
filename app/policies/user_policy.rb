class UserPolicy < ApplicationPolicy
  def index?
    barito_superadmin?
  end
end