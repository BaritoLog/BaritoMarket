class AppGroupsController < ApplicationController
  include Wisper::Publisher
  before_action :set_app_group, only: %i(show update manage_access)

  def index
    @allow_create_app_group = policy(AppGroup).new?

    (@filterrific = initialize_filterrific(
      policy_scope(AppGroup.left_outer_joins(:app_group_bookmarks).order(
        Arel::Nodes::Case.new.when(AppGroupBookmark.arel_table['user_id'].eq(current_user.id)).then(0).else(1))),
      params[:filterrific],
      sanitize_params: true,
    )) || return

    @app_groups = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def search
    @app_groups = policy_scope(AppGroup).
      where('name ILIKE :q', q: "%#{params[:q]}%")
    render json: @app_groups
  end

  def show
    authorize @app_group
    @apps = @app_group.barito_apps.order(:name)
    @new_app = BaritoApp.new(app_group_id: @app_group.id)
    @barito_router_url = "#{Figaro.env.router_protocol}://#{Figaro.env.router_domain}/produce_batch"
    @open_kibana_url = "#{Figaro.env.viewer_protocol}://#{Figaro.env.viewer_domain}/#{@app_group.infrastructure.cluster_name}"

    @allow_set_status = policy(@new_app).toggle_status?
    @allow_manage_access = policy(@app_group).manage_access?
    @allow_see_infrastructure = policy(Infrastructure).show?
    @allow_delete_barito_app = policy(@new_app).delete?
    @allow_add_barito_app = policy(@new_app).create?
    @allow_edit_metadata = policy(@app_group).update?
    @allow_delete_infrastructure = policy(@app_group.infrastructure).delete?
  end

  def new
    authorize AppGroup
    @app_group = AppGroup.new
  end

  def create
    authorize AppGroup
    @app_group, @infrastructure = AppGroup.setup(app_group_params)
    if @app_group.valid? && @infrastructure.valid?
      broadcast(:team_count_changed)
      return redirect_to root_path
    else
      flash[:messages] = @app_group.errors.full_messages
      flash[:messages] << @infrastructure.errors.full_messages
      return redirect_to new_app_group_path
    end
  end

  def update
    authorize @app_group
    @app_group.update_attributes(app_group_params)
    @app_group.infrastructure.update_attributes(infrastructure_params)
    broadcast(:app_group_updated, @app_group.id)
    redirect_to app_group_path(@app_group)
  end

  def manage_access
    authorize @app_group
    @app_group_user = AppGroupUser.new(app_group: @app_group)
    @app_group_users = AppGroupUser.
      includes(:user, :role).
      where(app_group_id: @app_group.id).
      order(:created_at)

    @roles = {
      member: AppGroupRole.find_by_name('member'),
      admin: AppGroupRole.find_by_name('admin'),
      owner: AppGroupRole.find_by_name('owner'),
    }
  end

  private

  def app_group_params
    params.require(:app_group).permit(
      :name,
      :cluster_template_id,
      :environment,
    )
  end

  def infrastructure_params
    params.require(:app_group).permit(
        :name
    )
  end

  def set_app_group
    @app_group = AppGroup.find(params[:id])
  end
end
