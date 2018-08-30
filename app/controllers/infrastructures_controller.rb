class InfrastructuresController < ApplicationController
  before_action :set_infrastructure
  before_action do
    authorize @infrastructure
  end

  def show
    @infrastructure_components = @infrastructure.infrastructure_components.order(:sequence)
  end

  def retry_bootstrap
    @infrastructure_component = InfrastructureComponent.find(
      params[:infrastructure_component_id])
    if @infrastructure_component.allow_bootstrap?
      @infrastructure_component.update_status('BOOTSTRAP_STARTED')
      RetryBootstrapWorker.perform_async(@infrastructure_component.id)
    end
    redirect_to infrastructure_path(@infrastructure.id)
  end

  def toggle_status
    statuses = Infrastructure.statuses
    @infrastructure.status = params[:toggle_status] == 'true' ? statuses[:active] : statuses[:inactive]
    @infrastructure.save!

    redirect_to app_groups_path
  end

  private

  def set_infrastructure
    @infrastructure = Infrastructure.find(params[:id])
  end
end
