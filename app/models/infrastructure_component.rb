class InfrastructureComponent < ApplicationRecord
  validates :infrastructure, :hostname, :component_type, :sequence, :status,
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
    bootstrap_finished: 'BOOTSTRAP_FINISHED',
    finished: 'FINISHED',
    delete_started: 'DELETE_STARTED',
    delete_error: 'DELETE_ERROR',
    deleted: 'DELETED',
  }

  filterrific :default_filter_params => { :sorted_by => 'created_at_desc' },
  :available_filters => %w[
    sorted_by
    search_query
  ]

  scope :search_query, ->(query) {
    return nil  if query.blank?
    terms = query.downcase.split(/\s+/)
    terms = terms.map { |e|
      ('%' + e + '%').gsub(/%+/, '%')
    }
    num_or_conditions = 2
    where(
      terms.map {
        or_clauses = [
          "LOWER(hostname) LIKE ?",
          "LOWER(component_type) LIKE ?"
        ].join(' OR ')
        "(#{ or_clauses })"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :sorted_by, ->(sort_option) {
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    infrastructure_components = InfrastructureComponent.arel_table
    case sort_option.to_s
    when /^created_at_/
      order(infrastructure_components[:created_at].send(direction))
    when /^hostname_/
      order(infrastructure_components[:hostname].lower.send(direction))
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
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
