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

    response = ARGOCD_CLIENT.sync_application(infrastructure.cluster_name, Figaro.env.argocd_default_destination_name)

    response_body = response.env[:body]
    status = response.env[:status]
    reason_phrase = response.env[:reason_phrase]

    parsed_body = JSON.parse(response_body)
    message = parsed_body['message']

    if status == 200
      infrastructure.update_provisioning_status('DEPLOYMENT_FINISHED')
      infrastructure.update_status('ACTIVE')
      out = "#{reason_phrase}: #{status}"
    else
      infrastructure.update_provisioning_status('DEPLOYMENT_ERROR')
      out = "#{reason_phrase}: #{status}: #{message}"
    end

    infrastructure.update!(last_log:
      (
        <<~EOS
          Argo Application sync #{status == 200 ? "was initiated successfully" : "initiation was failed"}.

          #{invocation_info}

          Output:
          #{out}
        EOS
      ).strip
    )
  end
end
