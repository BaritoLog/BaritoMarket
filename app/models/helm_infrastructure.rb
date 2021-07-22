class HelmInfrastructure < ApplicationRecord
  CLUSTER_NAME_PADDING = 1000
  belongs_to :app_group
  belongs_to :helm_cluster_template
  validates :override_values, helm_values: true

  enum statuses: {
    inactive: 'INACTIVE',
    active: 'ACTIVE',
  }
  enum provisioning_statuses: {
    pending: 'PENDING',
    deployment_started: 'DEPLOYMENT_STARTED',
    deployment_finished: 'DEPLOYMENT_FINISHED',
    deployment_error: 'DEPLOYMENT_ERROR',
    delete_started: 'DELETE_STARTED',
    delete_error: 'DELETE_ERROR',
    deleted: 'DELETED',
    finished: 'FINISHED',
  }

  class << self
    def setup(params)
      helm_cluster_template = HelmClusterTemplate.find(params[:helm_cluster_template_id])
      helm_infrastructure = HelmInfrastructure.new(
        cluster_name:               Rufus::Mnemo.from_i(HelmInfrastructure.generate_cluster_index),
        app_group_id:               params[:app_group_id],
        helm_cluster_template_id:   helm_cluster_template.id,
        is_active:                  true,
        use_k8s_kibana:             true,
        override_values:            YAML.safe_load('{}'),
        provisioning_status:        HelmInfrastructure.provisioning_statuses[:pending],
        status:                     HelmInfrastructure.statuses[:inactive],
        max_tps:                    Figaro.env.DEFAULT_MAX_TPS
      )

      if helm_infrastructure.valid?
        helm_infrastructure.save
        helm_infrastructure.update_provisioning_status('PENDING')
        helm_infrastructure.update!(last_log: "Helm invocation job will be scheduled.")

        helm_infrastructure.reload
        helm_infrastructure.synchronize_async
      end
      helm_infrastructure
    end

    def generate_cluster_index
      HelmInfrastructure.all.size + CLUSTER_NAME_PADDING
    end
  end

  def synchronize_async
    HelmSyncWorker.perform_async id
  end

  def producer_address
    producer_address_format = Figaro.env.PRODUCER_ADDRESS_FORMAT
    is_active.presence and sprintf(producer_address_format, cluster_name)
  end

  def kibana_address
    kibana_address_format = Figaro.env.KIBANA_ADDRESS_FORMAT
    use_k8s_kibana.presence and sprintf(kibana_address_format, cluster_name)
  end

  def elasticsearch_address
    elasticsearch_address_format = Figaro.env.ES_ADDRESS_FORMAT
    sprintf(elasticsearch_address_format, cluster_name)
  end

  def values
    helm_cluster_template.values.deep_merge(override_values)
  end

  def app_group_name
    app_group&.name
  end

  def app_group_secret
    app_group&.secret_key
  end

  def active?
    self.status == HelmInfrastructure.statuses[:active]
  end

  def update_status(status)
    status = status.downcase.to_sym
    if HelmInfrastructure.statuses.key?(status)
      update_attribute(:status, HelmInfrastructure.statuses[status])
    else
      false
    end
  end

  def update_provisioning_status(status)
    status = status.downcase.to_sym
    if HelmInfrastructure.provisioning_statuses.key?(status)
      update_attribute(:provisioning_status, HelmInfrastructure.provisioning_statuses[status])
    else
      false
    end
  end

  def allow_delete?
    [
      'DEPLOYMENT_FINISHED',
      'DEPLOYMENT_ERROR',
      'FINISHED',
      'DELETE_ERROR'
    ].include?(self.provisioning_status) && self.status == 'INACTIVE'
  end


  # will be deleted along with cleanup legacy code
  def default_service_names
    {
      producer: 'barito-flow-producer',
      zookeeper: 'zookeeper',
      kafka: 'kafka',
      consumer: 'barito-flow-consumer',
      elasticsearch: 'elasticsearch',
      kibana: 'kibana',
    }
  end
end
