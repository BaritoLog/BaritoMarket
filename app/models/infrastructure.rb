class Infrastructure < ApplicationRecord
  CLUSTER_NAME_PADDING = 1000
  validates :app_group, :name, :capacity, :cluster_name, :provisioning_status, :status, :component_template, presence: true

  belongs_to :app_group
  belongs_to :component_template
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
    delete_started: 'DELETE_STARTED',
    delete_error: 'DELETE_ERROR',
    deleted: 'DELETED',
  }
  enum env_prefixes: {
    production: 'p', 
    staging: 's', 
    development: 'd', 
    uat: 'u', 
    internal: 'i', 
    integration: 'g', 
    test: 't',
  }

  def self.setup(env, params)
    component_template = ComponentTemplate.find(params[:component_template_id])
    infrastructure = Infrastructure.new(
      name:                 params[:name],
      cluster_name: Rufus::Mnemo.from_i(Infrastructure.generate_cluster_index),
      capacity:             component_template.name,
      provisioning_status:  Infrastructure.provisioning_statuses[:pending],
      status:               Infrastructure.statuses[:inactive],
      app_group_id:         params[:app_group_id],
      component_template_id: component_template.id,
    )

    if infrastructure.valid?
      infrastructure.save
      instances = JSON.parse(component_template.instances)
      components = infrastructure.generate_components(env, instances)
      BlueprintWorker.perform_async(
        components,
        infrastructure_id: infrastructure.id
      )
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
    "#{Figaro.env.router_domain}/produce_batch"
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

  def provisioning_error?
    [
      'PROVISIONING_ERROR',
      'PROVISIONING_CHECK_FAILED'
    ].include? self.provisioning_status
  end

  def allow_delete?
    [
      'PROVISIONING_FINISHED',
      'PROVISIONING_CHECK_FAILED',
      'PROVISIONING_CHECK_SUCCEED',
      'BOOTSTRAP_ERROR',
      'FINISHED',
      'DELETE_ERROR'
    ].include?(self.provisioning_status) && self.status == 'INACTIVE'
  end

  def generate_components(env, instances)
    components = []
    instances.each do |type, value|
      components += (1..value["count"]).map { |number| component_hash(type, number, env, value["seq"]) }
    end
    components.sort_by {|obj| obj[:seq]}
  end

  private

  def component_hash(type, count, env, seq)
    name = "#{Infrastructure.env_prefixes[env.to_sym]}-#{self.cluster_name}-#{type}-#{format('%02d', count.to_i)}"
    { name: name, type: type, seq: seq }
  end
end
