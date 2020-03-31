class InfrastructurePolicy < ApplicationPolicy
  def show?
    barito_superadmin?
  end

  def edit?
    barito_superadmin?
  end

  def update_manifests?
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

  def retry_provision_container?
    show?
  end

  def retry_bootstrap_container?
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
