class AppGroupsController < ApplicationController
  def index
    @app_groups = AppGroup.all
  end

  def show
    @app_group = AppGroup.find(params[:id])
    @apps = @app_group.barito_apps
    @app = BaritoApp.new
  end

  def new
    @app_group = AppGroup.new
    @capacity_options = TPS_CONFIG.keys
  end

  def create
    @app_group, @infrastructure = AppGroup.setup(Rails.env, app_group_params)
    if @app_group.valid? && @infrastructure.valid?
      return redirect_to root_path
    else
      flash[:messages] = @app_group.errors.full_messages
      flash[:messages] << @infrastructure.errors.full_messages
      return redirect_to new_app_group_path
    end
  end

  private

  def app_group_params
    params.require(:app_group).permit(
      :name,
      :capacity
    )
  end
end
