class InfrastructuresController < ApplicationController
  def show
    @infrastructure = Infrastructure.find(params[:id])
    @infrastructure_components = @infrastructure.infrastructure_components
  end
end
