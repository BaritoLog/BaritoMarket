class AppsController < ApplicationController
  include Wisper::Publisher

  before_action :set_app, except: :create
  before_action except: :create do
    authorize @app
  end

  def create
    @app = BaritoApp.new(app_group_id: app_params[:app_group_id])
    authorize @app

    @app = BaritoApp.setup(app_params)
    @app.update(labels: @app.app_group.labels)

    if @app.persisted?
      audit_log  :create, { "app_name" => @app.name }
      broadcast(:app_count_changed)
      return redirect_to @app.app_group
    else
      flash[:messages] = @app.errors.full_messages
      return redirect_to @app.app_group
    end
  end

  def update
    authorize @app
    if app_params[:max_tps].to_i > @app.app_group.max_tps
      flash[:alert] = "Max TPS (#{app_params[:max_tps]} TPS) should be less than AppGroup capacity (#{@app.app_group.max_tps} TPS)"
      return redirect_to app_group_path(@app.app_group)
    elsif @app.app_group.new_total_tps(app_params[:max_tps].to_i - @app.max_tps) > @app.app_group.max_tps
      flash[:alert] = "With this new max TPS (#{app_params[:max_tps]} TPS), new AppGroup total TPS (#{@app.app_group.new_total_tps(app_params[:max_tps].to_i - @app.max_tps)} TPS)  will exceed AppGroup capacity"
      return redirect_to app_group_path(@app.app_group)
    end
    @app.update_attributes(app_params)

    audit_log  :update_app, { "params" => app_params.slice(:max_tps).to_h }
    broadcast(:app_updated, @app.app_group.secret_key, @app.secret_key, @app.name)
    redirect_to app_group_path(@app.app_group)
  end

  def update_log_retention_days
    from_reten_days = @app.log_retention_days
    @app.update(params.require(:barito_app).permit(:log_retention_days))
    audit_log  :update_retention, {
      "from_retention_days" => from_reten_days,
      "to_retention_days" => @app.log_retention_days
    }
    redirect_to app_group_path(@app.app_group)
  end

  def destroy
    secret_key = @app.secret_key
    app_group_secret_key = @app.app_group.secret_key
    app_name = @app.name
    @app.destroy
    audit_log  :delete_app, { "app_name" => app_name }
    broadcast(:app_count_changed)
    broadcast(:app_destroyed, app_group_secret_key, secret_key, app_name)
    return redirect_to @app.app_group
  end

  def toggle_status
    statuses = BaritoApp.statuses
    @app.update_attributes(status: params[:toggle_status] == 'true' ? statuses[:active] : statuses[:inactive])

    redirect_to app_group_path(params[:app_group_id])
  end

  def update_labels
    from_labels = @app.labels
    labels = {}

    if params[:keys].present? && params[:values].present?
      params[:keys].zip(params[:values]).each do |key,val|
        unless val.empty? || key.empty?
          labels.store(key, val)
        end
      end
    end


    @app.update(labels: labels)
    broadcast(:app_updated, @app.app_group.secret_key, @app.secret_key, @app.name)

    audit_log :update_labels, {
      "from_labels" => from_labels,
      "to_labels" => labels
    }

    redirect_to app_group_path(@app.app_group)
  end

  def update_redact_labels
    from_labels = @app.redact_labels
    redact_labels = {}

    if params[:keys].present? && params[:values].present? && params[:types].present? && params[:hintCharStart].present? && params[:hintCharEnd].present?
      params[:keys].zip(params[:values], params[:types], params[:hintCharStart], params[:hintCharEnd]).each do |key,val,type,hintCharStart,hintCharEnd|
        unless val.empty? || key.empty? || type.empty?
          redact_labels.store(key,{value: val, type: type, hintCharStart: hintCharStart, hintCharEnd: hintCharEnd})
        end
      end
    end


    @app.update_attributes(redact_labels: redact_labels)

    broadcast(:app_updated, @app.app_group.secret_key, @app.secret_key, @app.name)
    broadcast(:redact_labels_updated, @app.app_group.cluster_name)

    audit_log :update_redact_labels, {
      "from_labels" => from_labels,
      "to_labels" => redact_labels
    }

    redirect_to app_group_path(@app.app_group)
  end

  private
    def app_params
      params.require(:barito_app).permit(
        :app_group_id,
        :name,
        :topic_name,
        :max_tps,
      )
    end

    def set_app
      @app = BaritoApp.find(params[:id])
      @app_group = @app.app_group
    end
end
