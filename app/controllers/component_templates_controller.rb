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
    @component_attributes = JSON.pretty_generate(@component_template.component_attributes)
  end

  def show
    authorize @component_template
    @component_attributes = JSON.pretty_generate(@component_template.component_attributes)
  end

  def create
    authorize ComponentTemplate
    component_attributes = component_template_params.clone
    component_attributes[:component_attributes] = JSON.parse(component_attributes[:component_attributes])
    @component_template = ComponentTemplate.new(component_attributes)

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
    component_attributes = component_template_params.clone
    component_attributes[:component_attributes] = JSON.parse(component_attributes[:component_attributes])
    @component_template.update_attributes(component_attributes)
    redirect_to component_template_path(@component_template)
  end

  private

  def component_template_params
    params.require(:component_template).permit(
      :name,
      :image,
      :component_attributes
    )
  end

  def set_component_template
    @component_template = ComponentTemplate.find(params[:id])
  end
end
