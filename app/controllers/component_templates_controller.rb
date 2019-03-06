class ComponentTemplatesController < ApplicationController
  before_action :set_component_template, only: %i(show destroy update)

  def index
    authorize ComponentTemplate
    @component_templates = ComponentTemplate.all
  end

  def new
    authorize ComponentTemplate
    @component_template = ComponentTemplate.new
  end

  def show
    authorize @component_template
    @instances = JSON.pretty_generate(@component_template.instances)
    @kafka_options = JSON.pretty_generate(@component_template.kafka_options)
  end

  def create
    authorize ComponentTemplate
    attributes = component_template_params.clone
    attributes[:instances] = JSON.parse(attributes[:instances])
    attributes[:kafka_options] = JSON.parse(attributes[:kafka_options])
    @component_template = ComponentTemplate.new(attributes)

    if @component_template.save
      redirect_to component_templates_path
    else
      flash[:messages] = @component_template.errors.full_messages
      render :new
    end
  end

  def destroy
    authorize ComponentTemplate
    infrastructures = Infrastructure.where(component_template: @component_template)
    if infrastructures.empty?
    	@component_template.destroy
    else
      flash[:messages] = @component_template.errors.full_messages

    end
  	redirect_to component_templates_path
  end

  private

  def component_template_params
    params.require(:component_template).permit(
      :env,
      :name,
      :max_tps,
      :instances,
      :kafka_options
    )
  end

  def set_component_template
    @component_template = ComponentTemplate.find(params[:id])
  end
end
