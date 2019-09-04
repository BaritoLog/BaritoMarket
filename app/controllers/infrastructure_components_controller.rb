class InfrastructureComponentsController < ApplicationController
  before_action :set_infrastructure_component, only: %i(edit update)
  #before_action do
  #  authorize @infrastructure_component
  #end

  def index
    authorize InfrastructureComponent
    
    (@filterrific = initialize_filterrific(
      policy_scope(InfrastructureComponent),
      params[:filterrific],
      sanitize_params: true,
    )) || return


    @infrastructure_components = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def search
    @infrastructure_components = policy_scope(InfrastructureComponent).
      where('name ILIKE :q', q: "%#{params[:q]}%")
    render json: @infrastructure_components
  end

  def edit
    authorize @infrastructure_component
    @bootstrappers = JSON.pretty_generate(@infrastructure_component.bootstrappers)
    @source = JSON.pretty_generate(@infrastructure_component.source)
    session[:return_to] ||= request.referer
  end

  def update
    authorize @infrastructure_component
    component_params = infrastructure_component_params.clone
    component_params[:bootstrappers] = JSON.parse(component_params[:bootstrappers])
    component_params[:source] = JSON.parse(component_params[:source])
    @infrastructure_component.update_attributes(component_params)
    redirect_to session.delete(:return_to)
  end

  def retry_bootstrap
    session[:return_to] ||= request.referer
    @infrastructure_component = InfrastructureComponent.find(
      params[:infrastructure_component_id])
    if @infrastructure_component.allow_bootstrap?
      @infrastructure_component.update_status('BOOTSTRAP_STARTED')
      RetryBootstrapWorker.perform_async(@infrastructure_component.id)
    end
    redirect_to session.delete(:return_to)
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
