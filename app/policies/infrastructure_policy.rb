class InfrastructurePolicy < ApplicationPolicy
  def show?
    return true if get_user_groups
  end

  def retry?
    show?
  end
end
