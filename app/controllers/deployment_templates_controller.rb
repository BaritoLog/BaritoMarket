class DeploymentTemplatesController < ApplicationController
  before_action :set_deployment_template, only: %i(show destroy update edit)

  def index
    authorize DeploymentTemplate
    @deployment_templates = DeploymentTemplate.all
  end

  def new
    authorize DeploymentTemplate
    @deployment_template = DeploymentTemplate.new
  end

  def edit
    authorize @deployment_template
    @source = JSON.pretty_generate(@deployment_template.source)
    @bootstrappers = JSON.pretty_generate(@deployment_template.bootstrappers)
  end

  def show
    authorize @deployment_template
    @bootstrappers = JSON.pretty_generate(@deployment_template.bootstrappers)
    @source = JSON.pretty_generate(@deployment_template.source)
  end

  def create
    authorize DeploymentTemplate
    ct_params_cloned = deployment_template_params.clone
    ct_params_cloned[:source] = JSON.parse(ct_params_cloned[:source])
    ct_params_cloned[:bootstrappers] = JSON.parse(ct_params_cloned[:bootstrappers])
    @deployment_template = DeploymentTemplate.new(ct_params_cloned)

    if @deployment_template.save
      redirect_to deployment_templates_path
    else
      flash[:messages] = @deployment_template.errors.full_messages
      render :new
    end
  end

  def destroy
    authorize DeploymentTemplate
    @deployment_template.destroy
    redirect_to deployment_templates_path
  end

  def update
    authorize @deployment_template
    ct_params_cloned = deployment_template_params.clone
    ct_params_cloned[:source] = JSON.parse(ct_params_cloned[:source])
    ct_params_cloned[:bootstrappers] = JSON.parse(ct_params_cloned[:bootstrappers])
    @deployment_template.update_attributes(ct_params_cloned)
    redirect_to deployment_template_path(@deployment_template)
  end

  private

  def deployment_template_params
    params.require(:deployment_template).permit(
      :name,
      :source,
      :bootstrappers
    )
  end

  def set_deployment_template
    @deployment_template = DeploymentTemplate.find(params[:id])
  end
end
