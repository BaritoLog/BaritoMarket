class InfrastructuresController < ApplicationController
  helper_method :show_retry_button

  def show
    @infrastructure = Infrastructure.find(params[:id])
    @infrastructure_components = @infrastructure.infrastructure_components.order(:sequence)
  end
  def show_retry_button(status)
    is_bootstrap_error(status)
  end
  def is_bootstrap_error(status)
    return status == 'BOOTSTRAP_ERROR'
  end

  def retry
    seq = params[:seq].to_i
    RetryBootstrapWorker.perform_async(seq, params[:infrastructure_id]) if is_bootstrap_error(params[:status])
    redirect_to infrastructure_path(params[:infrastructure_id])
  end
end
