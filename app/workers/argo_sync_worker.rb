class ArgoSyncWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(helm_infrastructure_id)
    infrastructure = HelmInfrastructure.find(helm_infrastructure_id)

    release_name = infrastructure.cluster_name
    repository = Figaro.env.HELM_REPOSITORY.to_s
    chart_name = Figaro.env.HELM_CHART_NAME.to_s
    chart_version = Figaro.env.HELM_CHART_VERSION.to_s

    configs = "Release name: #{release_name} \nChart name: #{chart_name} \nChart version: #{chart_version} \n"
    stdin_data = YAML.dump(infrastructure.values)

    invocation_info = (
      <<~EOS
        #{configs}
        Input:
        #{stdin_data}
      EOS
    ).strip

    infrastructure.update!(last_log:
      (
        <<~EOS
          Syncing Argo Application

          #{invocation_info}
        EOS
      ).strip
    )
    infrastructure.update_provisioning_status('DEPLOYMENT_STARTED')

    terminate_response = ARGOCD_CLIENT.terminate_operation(infrastructure.cluster_name, Figaro.env.argocd_default_destination_name)

    response = ARGOCD_CLIENT.sync_application(infrastructure.cluster_name, Figaro.env.argocd_default_destination_name)

    sleep Figaro.env.argocd_worker_sync_interval.to_i

    status = response.env[:status]
    if status == 200 
      infrastructure.update_provisioning_status('DEPLOYMENT_FINISHED')
      infrastructure.update_status('ACTIVE')
      infrastructure.update!(last_log:
        (
          <<~EOS
            Argo Application sync was initiated successfully, Check Argo Sync Status for current status.
  
            #{invocation_info}
  
            Output:
            #{response.env[:reason_phrase]}: #{status}
          EOS
        ).strip
      )
    else
      infrastructure.update_provisioning_status('DEPLOYMENT_ERROR')
      infrastructure.update!(last_log:
        (
          <<~EOS
            Argo Application sync initiation was failed.
  
            #{invocation_info}
  
            Output:
            #{response.env[:reason_phrase]}: #{status}
          EOS
        ).strip
      )
      return
    end
  end
end
