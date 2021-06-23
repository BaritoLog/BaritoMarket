require "open3"
require "shellwords"

class HelmSyncWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(helm_infrastructure_id)
    infrastructure = HelmInfrastructure.find(helm_infrastructure_id)

    release_name = infrastructure.cluster_name
    repository = Figaro.env.HELM_REPOSITORY.to_s
    chart_name = Figaro.env.HELM_CHART_NAME.to_s
    chart_version = Figaro.env.HELM_CHART_VERSION.to_s

    cmd = ["helm", "upgrade", release_name, chart_name, "--install", "--repo", repository, "--version", chart_version, "-f", "-"]
    stdin_data = YAML.dump(infrastructure.values)

    invocation_info = (
      <<~EOS
        Command: #{cmd.shelljoin}
        Input:
        #{stdin_data}
      EOS
    ).strip

    infrastructure.update!(last_log:
      (
        <<~EOS
          Running Helm.

          #{invocation_info}
        EOS
      ).strip
    )
    infrastructure.update_provisioning_status('DEPLOYMENT_STARTED')

    out, status = Open3.capture2e(*cmd, stdin_data: stdin_data)

    if status.success?
      infrastructure.update_provisioning_status('DEPLOYMENT_FINISHED')
      infrastructure.update_status('ACTIVE')
    else
      infrastructure.update_provisioning_status('DEPLOYMENT_ERROR')
    end

    infrastructure.update!(last_log:
      (
        <<~EOS
          Helm ran #{status.success? ? "successfully" : "with failure"}.

          #{invocation_info}

          Output:
          #{out}
        EOS
      ).strip
    )
  end
end
