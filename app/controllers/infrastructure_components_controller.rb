class InfrastructureComponentsController < ApplicationController
  before_action :set_infrastructure_component
  before_action do
    authorize @infrastructure_component
  end

  def edit
    authorize @infrastructure_component
    @bootstrap_attributes = JSON.pretty_generate(@infrastructure_component.bootstrap_attributes)
  end

  def update
    authorize @infrastructure_component
    component_params = infrastructure_component_params.clone
    component_params[:bootstrap_attributes] = JSON.parse(component_params[:bootstrap_attributes])
    @infrastructure_component.update_attributes(component_params)
    redirect_to infrastructure_path(@infrastructure_component.infrastructure)
  end

  private

  def infrastructure_component_params
    params.require(:infrastructure_component).permit(
      :bootstrap_attributes
    )
  end

  def set_infrastructure_component
    @infrastructure_component = InfrastructureComponent.find(params[:id])
  end
end
