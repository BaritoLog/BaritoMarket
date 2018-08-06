class InfrastructuresController < ApplicationController
  def show
    @infrastructure = Infrastructure.find(params[:id])
    @infrastructure_components = @infrastructure.infrastructure_components.order(:sequence)
  end

  def retry_bootstrap
    @infrastructure = Infrastructure.find(params[:id])
    @infrastructure_component = InfrastructureComponent.find(
      params[:infrastructure_component_id])
    if @infrastructure_component.allow_bootstrap?
      RetryBootstrapWorker.perform_async(@infrastructure_component.id)
    end
    redirect_to infrastructure_path(@infrastructure.id)
  end
end
