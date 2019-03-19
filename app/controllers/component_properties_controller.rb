class ComponentPropertiesController < ApplicationController
  before_action :set_component_property, only: %i(show destroy update edit)

  def index
    authorize ComponentProperty
    @component_properties = ComponentProperty.all
  end

  def new
    authorize ComponentProperty
    @component_property = ComponentProperty.new
  end

  def edit
    authorize @component_property
    @component_attributes = JSON.pretty_generate(@component_property.component_attributes)
  end

  def show
    authorize @component_property
    @component_attributes = JSON.pretty_generate(@component_property.component_attributes)
  end

  def create
    authorize ComponentProperty
    component_attributes = component_property_params.clone
    component_attributes[:component_attributes] = JSON.parse(component_attributes[:component_attributes])
    @component_property = ComponentProperty.new(component_attributes)

    if @component_property.save
      redirect_to component_properties_path
    else
      flash[:messages] = @component_property.errors.full_messages
      render :new
    end
  end

  def destroy
    authorize ComponentProperty
    @component_property.destroy
    redirect_to component_properties_path
  end

  def update
    authorize @component_property
    component_attributes = component_property_params.clone
    component_attributes[:component_attributes] = JSON.parse(component_attributes[:component_attributes])
    @component_property.update_attributes(component_attributes)
    redirect_to component_property_path(@component_property)
  end

  private

  def component_property_params
    params.require(:component_property).permit(
      :name,
      :component_attributes
    )
  end

  def set_component_property
    @component_property = ComponentProperty.find(params[:id])
  end
end
