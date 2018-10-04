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

    @dog.batch_metrics do
      @dog.emit_point(
        "barito.log_count", app_group.log_count, :app_group => "#{app_group.name}", :app_name => "#{app.name}")
      @dog.emit_point(
        "barito.log_throughput", app_log_throughput, :app_group => "#{app_group.name}", :app_name => "#{app.name}")
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
