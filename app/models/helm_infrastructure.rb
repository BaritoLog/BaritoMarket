class HelmInfrastructure < ApplicationRecord
  belongs_to :app_group
  belongs_to :helm_cluster_template
  validates :override_values, helm_values: true

  def synchronize_async
    HelmSyncWorker.perform_async id
  end

  def cluster_name
    app_group.infrastructure.cluster_name
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
