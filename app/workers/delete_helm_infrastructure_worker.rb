require "open3"
require "shellwords"

class DeleteHelmInfrastructureWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(helm_infrastructure_id)
    infrastructure = HelmInfrastructure.find(helm_infrastructure_id)

    release_name = infrastructure.cluster_name

    cmd = ["helm", "delete", release_name]
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
          Deleting Helm.

          #{invocation_info}
        EOS
      ).strip
    )
    infrastructure.update_provisioning_status('DELETE_STARTED')

    out, status = Open3.capture2e(*cmd)

    if status.success?
      infrastructure.update_provisioning_status('DELETED')
      infrastructure.update_status('INACTIVE')
    else
      infrastructure.update_provisioning_status('DELETE_ERROR')
    end

    infrastructure.update!(last_log:
      (
        <<~EOS
          Helm deleted #{status.success? ? "successfully" : "with failure"}.

          #{invocation_info}

          Output:
          #{out}
        EOS
      ).strip
    )
  end
end
