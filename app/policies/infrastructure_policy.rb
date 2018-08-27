class InfrastructurePolicy < ApplicationPolicy
  def show?
    return true if get_user_groups
  end

  def retry_bootstrap?
    show?
  end

  def toggle_status?
    return true if get_user_groups
    false
  end

  def exists?
    return true if get_user_groups and !@record.nil?

    app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
    app_group_ids.include?(record.id)
  end
end
