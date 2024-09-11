class BaritoAppPolicy < ApplicationPolicy
  def create?
    return true if barito_superadmin?

    app_group = record.app_group
    return false if app_group.nil?
    user.can_access_app_group? app_group, roles: %i(admin owner)
  end

  def delete?
    create?
  end

  def destroy?
    create?
  end

  def update?
    puts("inside update: user: ", user.inspect)
    create?
  end

  def update_log_retention_days?
    barito_superadmin?
  end

  def toggle_status?
    create?
  end

  def update_labels?
    barito_superadmin? || user.can_access_app_group?(record, roles: %i(admin owner))
  end

  # only applicable for admin and owner roles, need to revisit later
  def update_redact_labels?
    puts("user: ", user.inspect)
    barito_superadmin? || user.can_access_app_group?(record, roles: %i(admin owner))
  end
end
