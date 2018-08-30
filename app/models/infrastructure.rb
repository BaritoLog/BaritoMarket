class Infrastructure < ApplicationRecord
  CLUSTER_NAME_PADDING = 1000
  validates :app_group, :name, :capacity, :cluster_name, :provisioning_status, :status, presence: true
  validate  :capacity_valid_key?

  belongs_to :app_group
  has_many :infrastructure_components

  enum statuses: {
    inactive: 'INACTIVE',
    active: 'ACTIVE',
  }
  enum provisioning_statuses: {
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

  def capacity_valid_key?
    config_types = TPS_CONFIG.keys.map(&:downcase)
    errors.add(:capacity, 'Invalid Config Value') unless config_types.include?(capacity)
  end

  def self.setup(env, params)
    infrastructure = Infrastructure.new(
      name:                 params[:name],
      cluster_name: Rufus::Mnemo.from_i(Infrastructure.generate_cluster_index),
      capacity:             params[:capacity],
      provisioning_status:  Infrastructure.provisioning_statuses[:pending],
      status:               Infrastructure.statuses[:inactive],
      app_group_id:         params[:app_group_id],
    )

    if infrastructure.valid?
      infrastructure.save
      blueprint = Blueprint.new(infrastructure, env)
      blueprint_path = blueprint.generate_file
      BlueprintWorker.perform_async(blueprint_path)
    end
    infrastructure
  end

  def add_component(attrs, seq)
    InfrastructureComponent.create(
      infrastructure_id:  self.id,
      hostname:           attrs[:name] || attrs['name'],
      category:           attrs[:type] || attrs['type'],
      sequence:           seq,
      status:             InfrastructureComponent.statuses[:pending],
    )
  end

  def components_ready?
    infrastructure_components.all?{ |component| component.ready? }
  end

  def update_status(status)
    status = status.downcase.to_sym
    if Infrastructure.statuses.key?(status)
      update_attribute(:status, Infrastructure.statuses[status])
    else
      false
    end
  end

  def update_provisioning_status(status)
    status = status.downcase.to_sym
    if Infrastructure.provisioning_statuses.key?(status)
      update_attribute(:provisioning_status, Infrastructure.provisioning_statuses[status])
    else
      false
    end
  end

  def receiver_url
    "#{Figaro.env.router_protocol}://"\
    "#{Figaro.env.router_domain}/produce"
  end

  def viewer_url
    "#{Figaro.env.viewer_protocol}://"\
    "#{cluster_name}.#{Figaro.env.viewer_domain}"
  end

  def app_group_name
    app_group&.name
  end

  def active?
    self.status == Infrastructure.statuses[:active]
  end

  def self.generate_cluster_index
    Infrastructure.all.size + CLUSTER_NAME_PADDING
  end
end
