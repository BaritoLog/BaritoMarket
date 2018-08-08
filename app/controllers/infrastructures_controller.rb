class InfrastructuresController < ApplicationController
  before_action :set_infrastructure
  before_action  do
    authorize @infrastructure
  end

  def show
    @infrastructure_components = @infrastructure.infrastructure_components.order(:sequence)
  end

  def retry_bootstrap
    @infrastructure_component = InfrastructureComponent.find(
      params[:infrastructure_component_id])
    if @infrastructure_component.allow_bootstrap?
      RetryBootstrapWorker.perform_async(@infrastructure_component.id)
    end
    redirect_to infrastructure_path(@infrastructure.id)
  end

  private

  def set_infrastructure
    @infrastructure = Infrastructure.find(params[:id])
  end
end
