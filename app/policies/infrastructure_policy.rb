class InfrastructurePolicy < ApplicationPolicy
  def show?
    return true if get_user_groups
  end

  def retry_provision?
    show?
  end

  def provisioning_check?
    show?
  end

  def retry_bootstrap?
    show?
  end

  def toggle_status?
    return true if get_user_groups
    false
  end

  def delete_infrastructure?
    return true if get_user_groups

    AppGroupUser.
      joins(:role).
      where(user: user, app_group_roles: { name: [:owner] }).count > 0
  end

  def exists?
    return true if get_user_groups

    app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
    app_group_ids.include?(record.id)
  end
end
