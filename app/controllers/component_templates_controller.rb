class ComponentTemplatesController < ApplicationController
  before_action :set_component_template, only: %i(show destroy update edit)

  def index
    authorize ComponentTemplate
    @component_templates = ComponentTemplate.all
  end

  def new
    authorize ComponentTemplate
    @component_template = ComponentTemplate.new
  end

  def edit
    authorize @component_template
    @source = JSON.pretty_generate(@component_template.source)
    @bootstrappers = JSON.pretty_generate(@component_template.bootstrappers)
  end

  def show
    authorize @component_template
    @bootstrappers = JSON.pretty_generate(@component_template.bootstrappers)
    @source = JSON.pretty_generate(@component_template.source)
  end

  def create
    authorize ComponentTemplate
    ct_params_cloned = component_template_params.clone
    ct_params_cloned[:source] = JSON.parse(ct_params_cloned[:source])
    ct_params_cloned[:bootstrappers] = JSON.parse(ct_params_cloned[:bootstrappers])
    @component_template = ComponentTemplate.new(ct_params_cloned)

    if @component_template.save
      redirect_to component_templates_path
    else
      flash[:messages] = @component_template.errors.full_messages
      render :new
    end
  end

  def destroy
    authorize ComponentTemplate
    @component_template.destroy
    redirect_to component_templates_path
  end

  def update
    authorize @component_template
    ct_params_cloned = component_template_params.clone
    ct_params_cloned[:source] = JSON.parse(ct_params_cloned[:source])
    ct_params_cloned[:bootstrappers] = JSON.parse(ct_params_cloned[:bootstrappers])
    @component_template.update_attributes(ct_params_cloned)
    redirect_to component_template_path(@component_template)
  end

  private

  def component_template_params
    params.require(:component_template).permit(
      :name,
      :source,
      :bootstrappers
    )
  end

  def set_component_template
    @component_template = ComponentTemplate.find(params[:id])
  end
end
