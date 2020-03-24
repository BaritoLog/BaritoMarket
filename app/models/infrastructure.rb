class Infrastructure < ApplicationRecord
  CLUSTER_NAME_PADDING = 1000
  validates :app_group, :name, :capacity, :cluster_name, :provisioning_status, :status, :cluster_template, presence: true

  belongs_to :app_group
  belongs_to :cluster_template
  has_many :infrastructure_components

  enum statuses: {
    inactive: 'INACTIVE',
    active: 'ACTIVE',
  }
  enum provisioning_statuses: {
    pending: 'PENDING',
    deployment_started: 'DEPLOYMENT_STARTED',
    deployment_finished: 'DEPLOYMENT_FINISHED',
    deployment_error: 'DEPLOYMENT_ERROR',
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

  def self.setup(params)
    cluster_template = ClusterTemplate.find(params[:cluster_template_id])
    infrastructure = Infrastructure.new(
      name:                 params[:name],
      cluster_name: Rufus::Mnemo.from_i(Infrastructure.generate_cluster_index),
      capacity:             cluster_template.name,
      provisioning_status:  Infrastructure.provisioning_statuses[:pending],
      status:               Infrastructure.statuses[:inactive],
      app_group_id:         params[:app_group_id],
      cluster_template_id:  cluster_template.id,
      manifests:            cluster_template.manifests,
      options:              cluster_template.options,
    )

    if infrastructure.valid?
      infrastructure.save
      BlueprintWorker.perform_async(
        infrastructure_id: infrastructure.id
      )
    end
    infrastructure
  end

  def add_component(attrs, seq)
    component_type = attrs[:type] || attrs['type']
    component_template = DeploymentTemplate.find_by(name: component_type)

    InfrastructureComponent.create(
      infrastructure_id:  self.id,
      hostname:           attrs[:name] || attrs['name'],
      component_type:     component_type,
      source:             component_template.source,
      bootstrappers:      component_template.bootstrappers,
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

  def update_manifests(manifests)
    if manifests.nil? || manifests.empty?
      false
    else
      update_column(:manifests, manifests)
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

  def fetch_consul_hosts
    consul_manifest = find_manifest_by_type('consul')
    return [] if consul_manifest.nil?

    provisioner = PathfinderProvisioner.new(
      Figaro.env.pathfinder_host,
      Figaro.env.pathfinder_token,
      Figaro.env.pathfinder_cluster,
    )
    consul_deployment = provisioner.index_containers!(consul_manifest['name'], consul_manifest['cluster_name'])
    return [] if consul_deployment.empty?

    consul_hosts = consul_deployment.dig('data','containers').map { |c| 
      "#{c['ipaddress']}:#{Figaro.env.default_consul_port}" 
    } 

    consul_hosts
  end

  private

  def component_hash(type, count)
    name = "#{self.cluster_name}-#{type}-#{format('%02d', count.to_i)}"
    { name: name, type: type}
  end

  def find_manifest_by_type(type)
    self.manifests.find {|manifest| manifest['type'] == type }
  end
end
