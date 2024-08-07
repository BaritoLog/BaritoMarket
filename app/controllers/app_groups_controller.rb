class AppGroupsController < ApplicationController
  include Wisper::Publisher
  before_action :set_app_group, only: %i(show update update_app_group_name manage_access update_labels update_redact_labels toggle_redact_status)

  def index
    @allow_create_app_group = policy(AppGroup).new?

    (@filterrific = initialize_filterrific(
      policy_scope(
        AppGroup.eager_load(:app_group_bookmarks).order(
          Arel::Nodes::Case.new.when(AppGroupBookmark.arel_table['user_id'].eq(current_user.id)).
            then(0).
            else(1),
        ),
      ),
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
    @open_kibana_url = "#{Figaro.env.viewer_protocol}://#{Figaro.env.viewer_domain}/" +
      @app_group.helm_infrastructure.cluster_name.to_s + "/"
    @open_katulampa_url = sprintf(Figaro.env.MONITORING_LINK_FORMAT, @app_group.helm_infrastructure.cluster_name.to_s)
    @allow_set_status = policy(@new_app).toggle_status?
    @allow_manage_access = policy(@app_group).manage_access?
    @allow_see_infrastructure = policy(Infrastructure).show?
    @allow_see_helm_infrastructure = policy(HelmInfrastructure).show?
    @allow_delete_barito_app = policy(@new_app).delete?
    @allow_add_barito_app = policy(@new_app).create?
    @allow_edit_barito_app_log_retention_days = policy(@new_app).update_log_retention_days?
    @allow_edit_metadata = policy(@app_group).update?
    @allow_edit_app_group_name = policy(@app_group).update_app_group_name?
    @allow_delete_helm_infrastructure = policy(@app_group.helm_infrastructure).delete?
    @allow_manage_labels = policy(@app_group).update_labels?
    @allow_manage_redact = policy(@app_group).update_redact_labels?
    @required_labels = Figaro.env.DEFAULT_REQUIRED_LABELS.split(',', -1)
    @show_log_and_cost_col = Figaro.env.SHOW_LOG_AND_COST_COL == "true"
    @show_redact_pii = Figaro.env.SHOW_REDACT_PII == "true"

    @labels = {}
    if @app_group.labels.nil?
      @app_group.labels = {}
    end

    @labels.store('app-group', @app_group.labels)
    @apps.each do |app|
      @labels.store(app.name, app.labels)
    end

    @redact_labels = {}
    if @app_group.redact_labels.nil?
      @app_group.redact_labels = {}
    end
    @redact_labels.store('app-group', @app_group.redact_labels)

    @apps.each do |app|
      app_label = {}
      if !app.redact_labels.nil?
        app_label = app.redact_labels
      end
      @redact_labels.store(app.name, app_label)
    end
  end

  def new
    authorize AppGroup
    @app_group = AppGroup.new
    @required_labels = Figaro.env.DEFAULT_REQUIRED_LABELS.split(',', -1)
  end

  def create
    authorize AppGroup

    app_group_params = permitted_params

    if app_group_params[:labels].present?
      app_group_params[:labels].each do |key, val|
        if val.empty?
          flash[:messages] = ["Required #{key} values must be filled."]
          return redirect_to new_app_group_path
        end
      end
    else
      app_group_params[:labels] = {}
    end

    @app_group, @helm_infrastructure = AppGroup.setup(app_group_params)
    if @app_group.valid? && @helm_infrastructure.valid?
      audit_log :create_new_app_group, { "app_group_id" => @app_group.id, "app_group_name" => @app_group.name, "app_group" => @helm_infrastructure.cluster_name }
      broadcast(:team_count_changed)
      return redirect_to root_path
    else
      flash[:messages] = @app_group.errors.full_messages
      flash[:messages] << @helm_infrastructure.errors.full_messages
      return redirect_to new_app_group_path
    end
  end

  def update
    authorize @app_group

    app_group_params = permitted_params
    helm_infrastructure_params = app_group_params.delete(:helm_infrastructure) || {}

    @app_group.update_attributes(app_group_params)
    @app_group.helm_infrastructure.update_attributes(helm_infrastructure_params)

    audit_log :update_app_group, { "app_group_params" => app_group_params.to_h, "helm_infrastructure_params" => helm_infrastructure_params.to_h }
    broadcast(:app_group_updated, @app_group.id)
    redirect_to app_group_path(@app_group)
  end

  def update_app_group_name
    authorize @app_group

    from_name = @app_group.name
    name = params.permit(app_group: :name)['app_group']['name']

    @app_group.update_attributes(name: name)

    audit_log :update_app_group_name, { "from_name" => from_name, "to_name" => name }
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

    @app_group_team = AppGroupTeam.new(app_group: @app_group)

    @app_group_teams = AppGroupTeam.
      includes(:group).
      where(app_group_id: @app_group.id).
      order(:created_at)

    @roles = {
      member: AppGroupRole.find_by_name('member'),
      admin: AppGroupRole.find_by_name('admin'),
      owner: AppGroupRole.find_by_name('owner'),
    }
  end

  def bookmark
    bookmarked = AppGroupBookmark.where(
      app_group_id: params[:app_group_id], user_id: current_user.id,
    ).first

    if bookmarked
      bookmarked.delete
    else
      AppGroupBookmark.create(user_id: current_user.id, app_group_id: params[:app_group_id])
    end

    redirect_to request.referer
  end

  def update_labels
    authorize @app_group

    from_labels = @app_group.labels
    labels = {}

    if params[:keys].present? && params[:values].present?
      params[:keys].zip(params[:values]).each do |key,val|
        unless val.empty? || key.empty?
          labels.store(key, val)
        end
      end
    end

    @app_group.update(labels: labels)
    audit_log :update_labels, {
      "from_labels" => from_labels,
      "to_labels" => labels
    }

    redirect_to request.referer
  end

  def update_redact_labels
    authorize @app_group

    from_labels = @app_group.redact_labels
    redact_labels = {}

    if params[:keys].present? && params[:values].present? && params[:types].present? && params[:hintCharStart].present? && params[:hintCharEnd].present?
      params[:keys].zip(params[:values], params[:types], params[:hintCharStart], params[:hintCharEnd]).each do |key,val,type,hintCharStart,hintCharEnd|
        unless val.empty? || key.empty? || type.empty?
          redact_labels.store(key,{value: val, type: type, hintCharStart: hintCharStart, hintCharEnd: hintCharEnd})
        end
      end
    end

    @app_group.update(redact_labels: redact_labels)
    audit_log :update_redact_labels, {
      "from_labels" => from_labels,
      "to_labels" => redact_labels
    }

    broadcast(:redact_labels_updated, @app_group.helm_infrastructure.cluster_name)
    redirect_to request.referer
  end

  def toggle_redact_status
    puts("inside toggle redact status")
    statuses = AppGroup.redact_statuses
    puts("this is the param comming from frontend ", params[:toggle_redact_status])

    puts("this is the current status of app group ", @app_group.redact_status)

    from_status = @app_group.redact_status
    @app_group.redact_status = params[:toggle_redact_status] == 'true' ? statuses[:active] : statuses[:inactive]
    @app_group.save!

    audit_log :toggle_app_group_redact_status, { "from_status" => from_status, "to_status" => @app_group.redact_status }

    if params[:app_group_id]
      app_group = AppGroup.find(params[:app_group_id])
      redirect_to app_group_path(app_group)
    else
      redirect_to app_groups_path
    end
  end

  private

  def permitted_params
    params.require(:app_group).permit(
      :name,
      :log_retention_days,
      :cluster_template_id,
      :environment,
      helm_infrastructure: [
        :max_tps,
      ],
      labels: {},
      redact_labels: {},
    )
  end

  def set_app_group
    @app_group = AppGroup.find(params[:id])
  end
end
