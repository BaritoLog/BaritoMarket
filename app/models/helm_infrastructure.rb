class HelmInfrastructure < ApplicationRecord
  belongs_to :app_group
  belongs_to :helm_cluster_template
  validates :override_values, helm_values: true
  # validates :cluster_name, :provisioning_status, :status, :max_tps

  def self.setup(params)
    helm_cluster_template = HelmClusterTemplate.find(params[:helm_cluster_template_id])
    helm_infrastructure = HelmInfrastructure.new(
      app_group_id:              params[:app_group_id],
      helm_cluster_template_id:  helm_cluster_template.id,
      is_active: true,
      use_k8s_kibana: true,
      override_values: YAML.safe_load('{}'),
    )

    if helm_infrastructure.valid?
      helm_infrastructure.save
      helm_infrastructure.update!(last_log: "Helm invocation job will be scheduled.")
      helm_infrastructure.synchronize_async
    end
    helm_infrastructure
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
end
