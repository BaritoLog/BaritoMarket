class ArgoDeleteWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(helm_infrastructure_id)
    infrastructure = HelmInfrastructure.find(helm_infrastructure_id)

    if infrastructure.blank? || !infrastructure.active?
      logger.warn "helm_infrastructure with id #{helm_infrastructure_id} is not found or is inactive"
      return
    end

    if !infrastructure.allow_delete?
      logger.warn "helm_infrastructure with id #{helm_infrastructure_id} is not allowed to be deleted. status #{infrastructure.status}, provisioning_status #{infrastructure.provisioning_status}"
      return
    end

    release_name = infrastructure.cluster_name

    infrastructure.update!(last_log:
     (
       <<~EOS
        Deleting Argo Application.
       EOS
     ).strip
    )

    infrastructure.update_privisioning_status('DELETE_STARTED')
    ARGOCD_CLIENT.terminate_operation(infrastructure.cluster_name, Figaro.env.ARGOCD_DEFAULT_DESTINATION_NAME)
    response = ARGOCD_CLIENT.delete_application(infrastructure.cluster_name, Figaro.env.ARGOCD_DEFAULT_DESTINATION_NAME)

    status = response.env[:status]
    if status == 200
      infrastructure.update_provisioning_status('DELETED')
      infrastructure.update_status('INACTIVE')
      infrastructure.update!(lastlog:
        (
          <<~EOS
            Argo Application deleted.
          EOS
        ).strip
      )
    else
      infrastructure.update_provisioning_status('DELETE_ERROR')
      infrastructure.update!(lastlog:
        (
          <<~EOS
            Argo Application delete initiation was failed.

            Outout:
            #{response.env[:reason_phrase]}: #{status}
          EOS
        ).strip
      )
    end

  end
end
