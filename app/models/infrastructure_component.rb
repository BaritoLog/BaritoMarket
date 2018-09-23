class InfrastructureComponent < ApplicationRecord
  validates :infrastructure, :hostname, :category, :sequence, :status,
    presence: true

  belongs_to :infrastructure

  enum statuses: {
    pending: 'PENDING',
    provisioning_started: 'PROVISIONING_STARTED',
    provisioning_error: 'PROVISIONING_ERROR',
    provisioning_finished: 'PROVISIONING_FINISHED',
    provisioning_check_started: 'PROVISIONING_CHECK_STARTED',
    provisioning_check_failed: 'PROVISIONING_CHECK_FAILED',
    provisioning_check_succeed: 'PROVISIONING_CHECK_SUCCEED',
    bootstrap_started: 'BOOTSTRAP_STARTED',
    bootstrap_error: 'BOOTSTRAP_ERROR',
    finished: 'FINISHED',
    delete_started: 'DELETE_STARTED',
    delete_error: 'DELETE_ERROR',
    deleted: 'DELETED',
  }

  def update_status(status, message = nil)
    status = status.downcase.to_sym
    if InfrastructureComponent.statuses.key?(status)
      update_attribute(:status, InfrastructureComponent.statuses[status])
      update_attribute(:message, message || status)
    else
      false
    end
  end

  def ready?
    return false unless self.status == 'FINISHED'
    return true
  end

  def allow_provision?
    component_provisioning_error = [
      'PROVISIONING_ERROR',
      'PROVISIONING_CHECK_FAILED',
      'PENDING'
    ].include? self.status

    component_provisioning_error && self.infrastructure.provisioning_error?
  end

  def allow_provisioning_check?
    [
      'PROVISIONING_FINISHED',
      'PROVISIONING_CHECK_FAILED',
    ].include? self.status
  end

  def allow_bootstrap?
    [
      'PROVISIONING_CHECK_SUCCEED',
      'BOOTSTRAP_ERROR',
      'FINISHED',
    ].include? self.status
  end
end
