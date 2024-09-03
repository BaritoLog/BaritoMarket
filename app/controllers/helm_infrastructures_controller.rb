class HelmInfrastructuresController < ApplicationController
  include Wisper::Publisher

  before_action :configure_current_object, only: %i(show destroy update edit synchronize toggle_status delete)
  before_action :configure_data_attributes, only: %i(create update)

  def new
    authorize HelmInfrastructure
    @app_group = AppGroup.find(params[:app_group_id])
    @helm_infrastructure = HelmInfrastructure.new
  end

  def create
    authorize HelmInfrastructure

    @app_group = AppGroup.find(params[:app_group_id])

    helm_infra_params = params[:helm_infrastructure]
    @helm_infrastructure = HelmInfrastructure.setup(
      app_group_id: @app_group.id,
      override_values: helm_infra_params[:override_values],
      helm_cluster_template_id: helm_infra_params[:helm_cluster_template_id],
      infrastructure_location_id: helm_infra_params[:infrastructure_location_id],
      cluster_name: @app_group.cluster_name
    )

    if @helm_infrastructure.valid?
      audit_log :create_new_helm_infrastructure, { "app_group_id" => @app_group.id, "app_group_name" => @app_group.name, "app_group" => @app_group.cluster_name, "location" => @helm_infrastructure.location_name }
      broadcast(:team_count_changed)

      return redirect_to app_group_path(@app_group)
    else
      flash[:messages] = @helm_infrastructure.errors.full_messages
      render :new
    end
  end

  def show
    authorize @helm_infrastructure
    @values = YAML.dump(@helm_infrastructure.values)
    @argocd_enabled = Figaro.env.ARGOCD_ENABLED == "true"
    @argo_operation_message, @argo_operation_phase = ARGOCD_CLIENT.check_sync_operation_status(@helm_infrastructure.cluster_name, @helm_infrastructure.location_name)
    @argo_application_health = ARGOCD_CLIENT.check_application_health_status(@helm_infrastructure.cluster_name, @helm_infrastructure.location_name)
    @argo_sync_duration = ARGOCD_CLIENT.sync_duration(@helm_infrastructure.cluster_name, @helm_infrastructure.location_name)
    @argo_application_url = ARGOCD_CLIENT.get_application_url(@helm_infrastructure)
  end

  def edit
    authorize @helm_infrastructure
    @override_values = YAML.dump(@helm_infrastructure.override_values)
  end

  def update
    authorize @helm_infrastructure

    from_attributes = @helm_infrastructure.attributes.slice("helm_cluster_template_id", "override_values", "is_active", "use_k8s_kibana")
    if @helm_infrastructure.update(@data_attributes)
      audit_log :update_helm_infrastructure, {
        "from_attributes" => from_attributes,
        "to_attributes" => @data_attributes.slice(:helm_cluster_template_id, :override_values, :is_active, :use_k8s_kibana)
      }
      broadcast(:app_group_updated, @helm_infrastructure.app_group.id)

      if Figaro.env.ARGOCD_ENABLED == 'true'
        response = ARGOCD_CLIENT.create_application(
          @helm_infrastructure.cluster_name, @helm_infrastructure.values,
          @helm_infrastructure.location_name, @helm_infrastructure.location_server)
        response_body = response.env[:body]
        status = response.env[:status]
        reason_phrase = response.env[:reason_phrase]

        parsed_body = JSON.parse(response_body)
        message = parsed_body['message']

        if status != 200
          flash[:messages] = ["#{reason_phrase}: #{status}: #{message}"]
          render :edit
          return
        end
      end

      redirect_to helm_infrastructure_path(@helm_infrastructure)
    else
      flash[:messages] = @helm_infrastructure.errors.full_messages
      render :edit
    end
  end

  def synchronize
    authorize @helm_infrastructure

    if Figaro.env.ARGOCD_ENABLED == 'true'
      @helm_infrastructure.update!(last_log: "Argo Application sync will be scheduled.")
      @helm_infrastructure.argo_upsert_and_sync
    else
      @helm_infrastructure.update!(last_log: "Helm invocation job will be scheduled.")
      @helm_infrastructure.synchronize_async
    end

    redirect_to helm_infrastructure_path(@helm_infrastructure)
  end

  def toggle_status
    statuses = HelmInfrastructure.statuses

    from_status = @helm_infrastructure.status
    @helm_infrastructure.status = params[:toggle_status] == 'true' ? statuses[:active] : statuses[:inactive]
    @helm_infrastructure.save!

    audit_log :toggle_helm_infrastructure_status, { "from_status" => from_status, "to_status" => @helm_infrastructure.status }

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

    if Figaro.env.ARGOCD_ENABLED == 'true'
      @helm_infrastructure.delete
    else
      @helm_infrastructure.update_provisioning_status('DELETE_STARTED')
      DeleteHelmInfrastructureWorker.perform_async(@helm_infrastructure.id)
    end

    audit_log :delete_helm_infrastructure, { "helm_infrastructure_id" => @helm_infrastructure.id }
    redirect_to app_group_path(app_group)
  end

  private

  def configure_current_object
    @helm_infrastructure = HelmInfrastructure.find(params[:id])
    @app_group = @helm_infrastructure.app_group
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
