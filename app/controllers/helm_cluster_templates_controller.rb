class HelmClusterTemplatesController < ApplicationController

  before_action :configure_current_object, only: %i(show destroy update edit)

  def index
    authorize HelmClusterTemplate
    @helm_cluster_template = HelmClusterTemplate.all
  end

  def new
    authorize HelmClusterTemplate
    @helm_cluster_template = HelmClusterTemplate.new
    @values = YAML.dump(@helm_cluster_template.values)
  end

  def edit
    authorize @helm_cluster_template
    @values = YAML.dump(@helm_cluster_template.values)
  end

  def show
    authorize @helm_cluster_template
    @values = YAML.dump(@helm_cluster_template.values)
  end

  def create
    authorize HelmClusterTemplate
    attributes = helm_cluster_template_params.clone
    attributes[:values] = YAML.safe_load(attributes[:values])
    @helm_cluster_template = HelmClusterTemplate.new(attributes)

    if @helm_cluster_template.save
      audit_log :create_helm_cluster_template, { "helm_cluster_template_name" => @helm_cluster_template.name }
      redirect_to helm_cluster_templates_path
    else
      flash[:messages] = @helm_cluster_template.errors.full_messages
      render :new
    end

  end

  def destroy
  end

  def update
    authorize @helm_cluster_template
    from_attributes = @helm_cluster_template.attributes
    attributes = helm_cluster_template_params.clone
    attributes[:values] = YAML.safe_load(attributes[:values])

    if @helm_cluster_template.update(attributes)
      audit_log :update_helm_cluster_template, { "from_attributes" => from_attributes, "to_attributes" => attributes }
      redirect_to helm_cluster_template_path(@helm_cluster_template)
    else
      flash[:messages] = @helm_cluster_template.errors.full_messages
      render :edit
    end
  end

  private

  def helm_cluster_template_params
    params.require(:helm_cluster_template).permit(
    :name,
    :values,
    :max_tps
    )
  end

  def configure_current_object
    @helm_cluster_template = HelmClusterTemplate.find(params[:id])
  end
end
