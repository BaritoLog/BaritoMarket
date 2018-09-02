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
    statuses = Infrastructure.statuses
    @infrastructure.status = params[:toggle_status] == 'true' ? statuses[:active] : statuses[:inactive]
    @infrastructure.save!

    if params[:app_group_id]
      app_group = AppGroup.find(params[:app_group_id])
      redirect_to app_group_path(app_group)
    else
      redirect_to app_groups_path
    end
  end

  def delete_infrastructure
    app_group = @infrastructure.app_group
    barito_apps = app_group.barito_apps
    barito_apps.each do |app|
      app.update_status('INACTIVE') if app.status == BaritoApp.statuses[:active]
    end
    @infrastructure.update_provisioning_status('DELETE_STARTED')
    DeleteInfrastructureWorker.perform_async(@infrastructure.id)

    redirect_to app_groups_path
  end

  private

  def set_infrastructure
    @infrastructure = Infrastructure.find(params[:id])
  end
end
