class InfrastructurePolicy < ApplicationPolicy
  def show?
    return true if get_user_groups

    app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
    app_group_ids.include?(record.id)
  end

  def retry?
    show?
  end
end
