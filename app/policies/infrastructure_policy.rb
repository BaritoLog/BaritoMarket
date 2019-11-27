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
    user.can_access_app_group? record.app_group, roles: %i(owner)
  end

  def exists?
    return true if barito_superadmin?
    user.can_access_app_group? record.app_group
  end
end
