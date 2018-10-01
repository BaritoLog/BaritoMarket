class DatadogListener
  def initialize
    if Figaro.env.datadog_integration == 'true'
      @dog = Dogapi::Client.new(Figaro.env.datadog_api_key)
    end
  end

  def log_count_changed(app_id, app_log_throughput)
    return unless @dog

    app = BaritoApp.find_by(id: app_id)
    if app.nil?
      return
    end
    app_group = app.app_group
    app_group_log_count = AppGroup.sum(:log_count)

    @dog.batch_metrics do
      @dog.emit_point("barito.app.#{app_group.name}.#{app.name}.log_count", app.log_count)
      @dog.emit_point(
        "barito.app_group.#{app_group.name}.log_count", app_group.log_count)
      @dog.emit_point(
        "barito.app.#{app_group.name}.#{app.name}.log_throughput", app_log_throughput)
      @dog.emit_point(
          "barito.app_group.log_count", app_group_log_count)
    end
  end

  def app_count_changed
    return unless @dog
    app_count = AppGroup.joins(:barito_apps, :infrastructure).where.not(infrastructures: { provisioning_status: "DELETED" }).count
    @dog.emit_point("barito.total_app", app_count)
  end

  def team_count_changed
    return unless @dog
    team_count = AppGroup.joins(:infrastructure).where.not(infrastructures: { provisioning_status: "DELETED"}).count
    @dog.emit_point("barito.total_team", team_count)
  end
end
