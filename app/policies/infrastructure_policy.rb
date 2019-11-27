class InfrastructurePolicy < ApplicationPolicy
  def show?
    barito_superadmin?
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
    barito_superadmin?
  end

  def delete?
    barito_superadmin? || user.can_access_app_group?(record.app_group, roles: %i(owner))
  end

  def exists?
    barito_superadmin? || user.can_access_app_group?(record.app_group)
  end
end
