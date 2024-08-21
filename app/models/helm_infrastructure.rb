class HelmInfrastructure < ApplicationRecord
  belongs_to :app_group, required: true
  belongs_to :helm_cluster_template, required: true
  belongs_to :infrastructure_location, required: true

  validates :override_values, helm_values: true
  validates :infrastructure_location_id, uniqueness: { scope: :app_group_id }

  enum statuses: {
    inactive: 'INACTIVE',
    active: 'ACTIVE',
  }
  scope :inactive, -> { where(status: statuses[:inactive]) }
  scope :active, -> { where(status: statuses[:active]) }

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
        cluster_name:               params[:cluster_name],
        app_group_id:               params[:app_group_id],
        helm_cluster_template_id:   helm_cluster_template.id,
        is_active:                  true,
        use_k8s_kibana:             true,
        infrastructure_location_id: params[:infrastructure_location_id],
        override_values:            params[:override_values].present? ? YAML.safe_load(params[:override_values]) : YAML.safe_load('{}'),
        provisioning_status:        HelmInfrastructure.provisioning_statuses[:pending],
        status:                     HelmInfrastructure.statuses[:inactive],
        max_tps:                    Figaro.env.DEFAULT_MAX_TPS
      )

      if helm_infrastructure.valid?
        helm_infrastructure.save
        helm_infrastructure.update_provisioning_status('PENDING')
        helm_infrastructure.reload

        infra_location = helm_infrastructure.infrastructure_location

        if Figaro.env.ARGOCD_ENABLED == 'true'
          helm_infrastructure.argo_upsert_and_sync
        else
          helm_infrastructure.update!(last_log: "Helm invocation job will be scheduled.")
          helm_infrastructure.synchronize_async
        end
      end
      helm_infrastructure
    end
  end

  def synchronize_async
    worker = HelmSyncWorker.new
    worker.perform id
  end

  def is_elastalert_enabled
    get_override_values_path('elastalert.enabled')
  end

  def is_kafka_ext_listener_enabled
    get_override_values_path('kafka.externalListener.enable')
  end

  def is_cold_storage_enabled
    get_override_values_path('elasticsearch.archival.enabled')
  end

  def get_override_values_path(path)
    keys = path.split('.')
    keys.reduce(override_values) do |hash, key|
      hash[key] if hash.is_a?(Hash)
    end
  end

  def cluster_name
    app_group.cluster_name
  end

  def argo_synchronize_async
    # ArgoSyncWorker.perform_async id
    w = ArgoSyncWorker.new
    w.perform id
  end

  def argo_application_url
    "#{Figaro.env.ARGOCD_URL}/applications/argocd/#{Figaro.env.argocd_project_name}-#{cluster_name}-#{location_name}"
  end

  # call this during mass sync of app groups or when new app group is created
  def argo_upsert_and_sync
    response = ARGOCD_CLIENT.create_application(
      cluster_name, self.values,
      self.location_name, self.location_server
    )
    status = response.env[:status]
    reason_phrase = response.env[:reason_phrase]

    parsed_body = JSON.parse(response.env[:body])
    message = parsed_body['message']

    if status != 200
      puts("Error in application manifest update: #{reason_phrase}: #{status}: #{message}")
    else
      self.update!(last_log: "Argo Application sync will be scheduled.")
      self.argo_synchronize_async
    end
  end

  def producer_address
    if infrastructure_location.nil?
      # TODO: remove this after all helm_infrastructure has infrastructure_location
      producer_address_format = Figaro.env.PRODUCER_ADDRESS_FORMAT
      is_active.presence and sprintf(producer_address_format, cluster_name)
    else
      sprintf(infrastructure_location.producer_address_format, cluster_name)
    end
  end

  def kibana_address
    if infrastructure_location.nil?
      # TODO: remove this after all helm_infrastructure has infrastructure_location
      kibana_address_format = Figaro.env.KIBANA_ADDRESS_FORMAT
      use_k8s_kibana.presence and sprintf(kibana_address_format, cluster_name)
    else
      sprintf(infrastructure_location.kibana_address_format, cluster_name)
    end
  end

  def delete
    self.update_provisioning_status('DELETE_STARTED')
    app_group = self.app_group
    if app_group.producer_helm_infrastructure_id == self.id
      app_group.update(producer_helm_infrastructure_id: nil)
    end

    if app_group.kibana_helm_infrastructure_id == self.id
      app_group.update(kibana_helm_infrastructure_id: nil)
    end
    ArgoDeleteWorker.perform_async(@helm_infrastructure.id)
  end

  def elasticsearch_address
    elasticsearch_address_format = Figaro.env.ES_ADDRESS_FORMAT
    sprintf(elasticsearch_address_format, cluster_name)
  end

  def producer_mtls_enabled?
    infrastructure_location.is_mtls_enabled ? true : false
  end

  def kibana_mtls_enabled?
    infrastructure_location.is_mtls_enabled ? true : false
  end

  def values
    inject_values = {
      "clusterNameLocation" => location_name,
    }

    if producer_mtls_enabled? || kibana_mtls_enabled?
      inject_values["istio"] = {
        "gateway" => {
          "enabled" => "true",
          "tls" => {
            "enabled" => "true",
          }
        },
        "authorizationPolicy" => {
          "enabled" => "true",
        }
      }
    end

    if producer_mtls_enabled?
      inject_values["producer"] = { "virtualService" => { "enabled" => "true" } }
    end

    if kibana_mtls_enabled?
      inject_values["kibana"] = { "virtualService" => { "enabled" => "true" } }
    end

    inject_values.deep_merge(helm_cluster_template.values).deep_merge(override_values)
  end

  def location_name
    infrastructure_location.name
  end

  def location_server
    infrastructure_location.destination_server
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
