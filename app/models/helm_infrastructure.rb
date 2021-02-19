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
    is_active.presence and "#{cluster_name}-barito-worker-producer.barito-worker.svc:8080"
  end

  def kibana_address
    use_k8s_kibana.presence and "#{cluster_name}-barito-worker-kb-http.barito-worker.svc:5601"
  end

  def elasticsearch_address
    "#{cluster_name}-barito-worker-es-http.barito-worker.svc"
  end

  def values
    helm_cluster_template.values.deep_merge(override_values)
  end
end
