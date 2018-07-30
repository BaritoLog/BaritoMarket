class InfrastructuresController < ApplicationController
  def show
    @infrastructure = Infrastructure.find(params[:id])
    @infrastructure_components = @infrastructure.infrastructure_components.order(:sequence)
  end

  def retry
    @infrastructure = Infrastructure.find(params[:id])
    @infrastructure_component = InfrastructureComponent.find(
      params[:infrastructure_component_id])
    if @infrastructure_component.bootstrap_error?
      RetryBootstrapWorker.perform_async(
        @infrastructure.id, @infrastructure_component.sequence)
    end
    redirect_to infrastructure_path(@infrastructure.id)
  end
end
