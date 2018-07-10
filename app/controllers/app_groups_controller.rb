class AppGroupsController < ApplicationController
  before_action :set_app_group, only: [:show, :manage_access]
  before_action only: [:show, :manage_access] do
    authorize @app_group
  end

  def index
    @app_groups = policy_scope(AppGroup)
  end

  def search
    @app_groups = AppGroup.where("name ILIKE :q", { q: "%#{params[:q]}%" })
    render json: @app_groups
  end

  def show
    @apps = @app_group.barito_apps
    @app = BaritoApp.new
    @allow_action = policy(@app_group).allow_action?
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

  def manage_access
    @app_group_admin = AppGroupAdmin.new(app_group: @app_group)
    @app_group_admins = AppGroupAdmin.includes(:user).where(app_group: @app_group)
    @app_group_permission = AppGroupPermission.new(app_group: @app_group)
    @group_permissions = AppGroupPermission.includes(:group).where(app_group: @app_group)
  end

  private

  def app_group_params
    params[:app_group][:user_id] = current_user.id
    params.require(:app_group).permit(
      :name,
      :capacity,
      :user_id
    )
  end

  def set_app_group
    @app_group = AppGroup.find(params[:id])
  end
end
