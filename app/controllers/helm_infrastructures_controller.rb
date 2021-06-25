class HelmInfrastructuresController < ApplicationController
  include Wisper::Publisher

  before_action :configure_current_object, only: %i(show destroy update edit synchronize toggle_status delete)
  before_action :configure_data_attributes, only: %i(create update)

  def new
    authorize HelmInfrastructure
    @helm_infrastructure = HelmInfrastructure.new
  end

  def create
    authorize HelmInfrastructure
    helm_infrastructure = HelmInfrastructure.new(@data_attributes)
    helm_infrastructure.app_group = AppGroup.find(params[:app_group_id])

    if helm_infrastructure.save
      redirect_to app_group_path(helm_infrastructure.app_group)
    else
      flash[:messages] = helm_infrastructure.errors.full_messages
      render :new
    end
  end

  def show
    authorize @helm_infrastructure
    @values = YAML.dump(@helm_infrastructure.values)
  end

  def edit
    authorize @helm_infrastructure
    @override_values = YAML.dump(@helm_infrastructure.override_values)
  end

  def update
    authorize @helm_infrastructure
    if @helm_infrastructure.update(@data_attributes)
      broadcast(:app_group_updated, @helm_infrastructure.app_group.id)
      redirect_to helm_infrastructure_path(@helm_infrastructure)
    else
      flash[:messages] = helm_infrastructure.errors.full_messages
    end
  end

  def synchronize
    authorize @helm_infrastructure
    @helm_infrastructure.update!(last_log: "Helm invocation job will be scheduled.")
    @helm_infrastructure.synchronize_async
    redirect_to helm_infrastructure_path(@helm_infrastructure)
  end

  def toggle_status
    statuses = HelmInfrastructure.statuses
    puts @helm_infrastructure
    @helm_infrastructure.status = params[:toggle_status] == 'true' ? statuses[:active] : statuses[:inactive]
    @helm_infrastructure.save!

    if params[:app_group_id]
      app_group = AppGroup.find(params[:app_group_id])
      redirect_to app_group_path(app_group)
    else
      redirect_to app_groups_path
    end
  end

  def delete
    app_group = @helm_infrastructure.app_group
    barito_apps = app_group.barito_apps
    barito_apps.each do |app|
      app.update_status('INACTIVE') if app.status == BaritoApp.statuses[:active]
    end
    @helm_infrastructure.update_provisioning_status('DELETE_STARTED')
    DeleteHelmInfrastructureWorker.perform_async(@helm_infrastructure.id)

    redirect_to app_groups_path
  end

  private

  def configure_current_object
    @helm_infrastructure = HelmInfrastructure.find(params[:id])
  end

  def configure_data_attributes
    @data_attributes = params.require(:helm_infrastructure).permit(
      :helm_cluster_template_id,
      :override_values,
      :is_active,
      :use_k8s_kibana,
    ).clone

    override_values_object = YAML.safe_load(@data_attributes[:override_values])
    @data_attributes[:override_values] = override_values_object
  end
end
