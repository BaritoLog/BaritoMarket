class InfrastructureComponentsController < ApplicationController
  before_action :set_infrastructure_component
  before_action do
    authorize @infrastructure_component
  end

  def edit
    authorize @infrastructure_component
    @bootstrappers = JSON.pretty_generate(@infrastructure_component.bootstrappers)
    @source = JSON.pretty_generate(@infrastructure_component.source)
  end

  def update
    authorize @infrastructure_component
    component_params = infrastructure_component_params.clone
    component_params[:bootstrappers] = JSON.parse(component_params[:bootstrappers])
    component_params[:source] = JSON.parse(component_params[:source])
    @infrastructure_component.update_attributes(component_params)
    redirect_to infrastructure_path(@infrastructure_component.infrastructure)
  end

  private

  def infrastructure_component_params
    params.require(:infrastructure_component).permit(
      :bootstrappers,
      :source
    )
  end

  def set_infrastructure_component
    @infrastructure_component = InfrastructureComponent.find(params[:id])
  end
end
