class InfrastructurePolicy < ApplicationPolicy
  def show?
    return true if barito_superadmin?
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
    return true if barito_superadmin?
    false
  end

  def delete?
    return true if barito_superadmin?
    record.app_group.app_group_users.
      joins(:role).
      where(user: user, app_group_roles: { name: [:owner] }).
      count.positive?
  end

  def exists?
    return true if barito_superadmin?
    app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
    app_group_ids.include?(record.id)
  end
end
