class InfrastructuresController < ApplicationController
  before_action :set_infrastructure
  before_action do
    authorize @infrastructure
  end

  def show
    @infrastructure_components = @infrastructure.infrastructure_components.order(:sequence)
  end

  def retry_provision
    @infrastructure_component = InfrastructureComponent.find(
      params[:infrastructure_component_id])
    if @infrastructure_component.allow_provision?
      @infrastructure_component.update_status('PROVISIONING_STARTED')
      RetryProvisionWorker.perform_async(@infrastructure_component.id)
    end
    redirect_to infrastructure_path(@infrastructure.id)
  end

  def provisioning_check
    @infrastructure_component = InfrastructureComponent.find(
      params[:infrastructure_component_id])
    if @infrastructure_component.allow_provisioning_check?
      @infrastructure_component.update_status('PROVISIONING_CHECK_STARTED')
      ProvisioningCheckWorker.perform_async(@infrastructure_component.id)
    end
    redirect_to infrastructure_path(@infrastructure.id)
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
    @infrastructure.status = (@infrastructure.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE')
    @infrastructure.save!

    redirect_to app_groups_path
  end

  private

  def set_infrastructure
    @infrastructure = Infrastructure.find(params[:id])
  end
end
