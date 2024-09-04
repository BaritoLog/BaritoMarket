class ArgoDeleteWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(helm_infrastructure_id)
    infrastructure = HelmInfrastructure.find(helm_infrastructure_id)

    if infrastructure.blank? || !infrastructure.active?
      logger.warn "helm_infrastructure with id #{helm_infrastructure_id} is not found or is inactive"
      return
    end

    infrastructure.update!(last_log:
     (
       <<~EOS
        Deleting Argo Application.
       EOS
     ).strip
    )

    infrastructure.update_provisioning_status('DELETE_STARTED')
    ARGOCD_CLIENT.terminate_operation(infrastructure.app_group.cluster_name, infrastructure.infrastructure_location.name)
    response = ARGOCD_CLIENT.delete_application(infrastructure.cluster_name, infrastructure.infrastructure_location.name)

    status = response.env[:status]
    parsed_body = JSON.parse(response.env[:body])
    message = parsed_body['message']
    if status == 200
      infrastructure.update!(last_log:
        (
          <<~EOS
            Argo Application deleted.
          EOS
        ).strip
      )
      infrastructure.update_provisioning_status('DELETED')
      infrastructure.update_status('INACTIVE')
    else
      infrastructure.update!(last_log:
        (
          <<~EOS
            Argo Application delete initiation was failed.

            Outout:
            #{response.env[:reason_phrase]}: #{status}: #{message}
          EOS
        ).strip
      )
      infrastructure.update_provisioning_status('DELETE_ERROR')
    end
  end
end
