class InfrastructuresController < ApplicationController
  before_action :set_infrastructure
  before_action do
    authorize @infrastructure
  end

  def show
    @manifests = JSON.pretty_generate(@infrastructure.manifests)
    @containers = get_containers
    @infrastructure_components = @infrastructure.infrastructure_components.order(:sequence)
  end

  def edit
    @manifests = JSON.pretty_generate(@infrastructure.manifests)
  end

  def update_manifests
    infrastructure_params = params['infrastructure']
    begin
      manifests = JSON.parse(infrastructure_params['manifests'])
    rescue JSON::ParserError
      @infrastructure.errors.add(:manifests, "Should be valid JSON")
      @manifests = JSON.pretty_generate(@infrastructure.manifests)
      render :edit
      return
    end

    success = @infrastructure.update_manifests(manifests)
    if success
      UpdateManifestsWorker.perform_async(@infrastructure.id)
    end
    redirect_to infrastructure_path
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

  def retry_provision_container
    container_hostname = params[:infrastructure_container_hostname]
    container_source = params[:infrastructure_component_source]
    container_bootstrappers = params[:infrastructure_component_bootstrappers]
    
    set_provisioner
    @provisioner.reprovision_container!(container_hostname, container_source, container_bootstrappers)
    
    redirect_to infrastructure_path(@infrastructure.id)
  end

  def retry_bootstrap_container
    container_hostname = params[:infrastructure_container_hostname]
    container_bootstrappers = params[:infrastructure_component_bootstrappers]
    
    set_provisioner
    @provisioner.rebootstrap_container!(container_hostname, container_bootstrappers)

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

  def delete
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

  def set_pathfinder_provisioner
    @pathfinder_provisioner = PathfinderProvisioner.new(
                  Figaro.env.pathfinder_host,
                  Figaro.env.pathfinder_token,
                  Figaro.env.pathfinder_cluster,
                 )
  end

  def set_provisioner
    set_pathfinder_provisioner
    @provisioner = BaritoBlueprint::Provisioner.new(
      @infrastructure,
      @pathfinder_provisioner
    )
  end

  def get_containers
    set_pathfinder_provisioner
    
    containers = []
    @infrastructure.manifests.each do |manifest|
      deployment = @pathfinder_provisioner.index_containers!(manifest['name'], manifest['cluster_name'])
      if deployment.empty?
        next
      end
      deployment_containers = deployment['data']['containers']
      containers += deployment_containers unless deployment_containers == nil 
    end
    containers
  end
end
