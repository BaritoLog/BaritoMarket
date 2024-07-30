class ArgoSyncWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(helm_infrastructure_id)
    infrastructure = HelmInfrastructure.find(helm_infrastructure_id)

    if infrastructure.blank? || !infrastructure.active?
      render json: {
        success: false,
        errors: ["Infrastructure not found"],
        code: 404
      }, status: :not_found and return
    end

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
    status = response.env[:status]
    out = "#{response.env[:reason_phrase]}: #{status}"
    infrastructure.update!(last_log:
      (
        <<~EOS
          Argo Application sync #{status == 200 ? "was initiated successfully, soon it will be synced." : "initiation was failed"}.

          #{invocation_info}

          Output:
          #{out}
        EOS
      ).strip
    )
    if status != 200
      return
    end

    timeout = 2 * 60 # 2 minutes by default
    interval = 15

    counter = timeout / interval
    lastPhase = ''
    lastMessage = ''

    for i in 1..counter do
      lastMessage, lastPhase = ARGOCD_CLIENT.check_sync_operation_status(infrastructure.cluster_name, Figaro.env.argocd_default_destination_name)
      if lastPhase == 'Succeeded' 
        break
      end
      sleep interval
    end

    if lastPhase == 'Running'
      terminate_response = ARGOCD_CLIENT.terminate_operation(infrastructure.cluster_name, Figaro.env.argocd_default_destination_name)
      infrastructure.update_provisioning_status('DEPLOYMENT_ERROR')
      if terminate_response.env[:status] == 200
        infrastructure.update!(last_log:
          (
            <<~EOS
              The Argo Application was not able to sync in 5 mins. Terminating the sync operation. \nReason: #{lastMessage}
    
              #{invocation_info}
            EOS
          ).strip
        )
      else
        infrastructure.update!(last_log:
          (
            <<~EOS
              The Argo Application was not able to sync in 5 mins. Sync process termination was not successful. \nReason: #{lastMessage}
    
              #{invocation_info}
            EOS
          ).strip
        )
      end
      
    elsif lastPhase == 'Failed'
      terminate_response = ARGOCD_CLIENT.terminate_operation(infrastructure.cluster_name, Figaro.env.argocd_default_destination_name)
      infrastructure.update_provisioning_status('DEPLOYMENT_ERROR')
      if terminate_response.env[:status] == 200
        infrastructure.update!(last_log:
          (
            <<~EOS
              The Argo Application sync was failed to sync. Terminating the sync operation. \nReason: #{lastMessage}
    
              #{invocation_info}
            EOS
          ).strip
        )
      else
        infrastructure.update!(last_log:
          (
            <<~EOS
              The Argo Application sync was failed to sync. Sync process termination was not successful. \nReason: #{lastMessage}
    
              #{invocation_info}
            EOS
          ).strip
        )
      end
      
    elsif lastPhase == 'Succeeded'
      infrastructure.update_provisioning_status('DEPLOYMENT_FINISHED')
      infrastructure.update!(last_log:
        (
          <<~EOS
            The Argo Application was synced successfully. Happy.
  
            #{invocation_info}
          EOS
        ).strip
      )
    end
  end
end
