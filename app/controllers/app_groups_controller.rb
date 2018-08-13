class AppGroupsController < ApplicationController
  before_action :set_app_group, only: [:show, :update, :manage_access]
  before_action only: [:show, :update, :manage_access] do
    authorize @app_group
  end

  def index
    @app_groups = policy_scope(AppGroup)
    @allow_create_app_group = policy(Group).index?
    @allow_set_status = policy(Infrastructure).toggle_status?
  end

  def search
    @app_groups = policy_scope(AppGroup).where("name ILIKE :q", { q: "%#{params[:q]}%" })
    render json: @app_groups
  end

  def show
    @apps = @app_group.barito_apps
    @app = BaritoApp.new
    @barito_router_url = "#{Figaro.env.router_protocol}://#{Figaro.env.router_domain}/produce"
    @open_kibana_url = "#{Figaro.env.viewer_protocol}://#{Figaro.env.viewer_domain}/#{@app_group.infrastructure.cluster_name}"

    @allow_manage_access = policy(@app_group).manage_access?
    @allow_see_infrastructure = policy(Infrastructure).show?
    @allow_see_apps = policy(@app_group).allow_see_apps?
    @allow_delete_barito_app = policy(@app).delete?
    @allow_add_barito_app = policy(@app).create?
    @allow_edit_metadata = policy(@app_group).update?
  end

  def new
    authorize AppGroup
    @app_group = AppGroup.new
    @capacity_options = TPS_CONFIG.keys
  end

  def create
    authorize AppGroup
    @app_group, @infrastructure = AppGroup.setup(Rails.env, app_group_params)
    if @app_group.valid? && @infrastructure.valid?
      return redirect_to root_path
    else
      flash[:messages] = @app_group.errors.full_messages
      flash[:messages] << @infrastructure.errors.full_messages
      return redirect_to new_app_group_path
    end
  end

  def update
    @app_group.update_attributes(app_group_params)
    redirect_to app_group_path(@app_group)
  end

  def manage_access
    @app_group_user = AppGroupUser.new(app_group: @app_group)
    @app_group_users = AppGroupUser.
      joins(:user, :role).
      group('users.email, users.username, user_id').
      select("user_id, string_agg(role_id::character varying, ',') AS roles, users.email, users.username")

    @role_member = AppGroupRole.as_member
    @roles = AppGroupRole.where.not(name: 'member')
  end

  private

  def app_group_params
    params.require(:app_group).permit(
      :name,
      :capacity
    )
  end

  def set_app_group
    @app_group = AppGroup.find(params[:id])
  end
end
