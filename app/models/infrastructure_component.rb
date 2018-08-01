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

  def any_errors?
    [
      'PROVISIONING_ERROR',
      'PROVISIONING_CHECK_FAILED',
      'BOOTSTRAP_ERROR',
    ].include? self.status
  end

  def provisioning_error?
    self.status == 'PROVISIONING_ERROR'
  end

  def provisioning_check_failed?
    self.status == 'PROVISIONING_CHECK_FAILED'
  end

  def bootstrap_error?
    self.status == 'BOOTSTRAP_ERROR'
  end
end
