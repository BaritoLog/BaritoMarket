require 'datadog/statsd'

class DatadogListener
  def initialize
    if Figaro.env.datadog_integration == 'true'
      @statsd = Datadog::Statsd.new(Figaro.env.datadog_host, Figaro.env.datadog_port)
    end
  end

  def log_count_changed(app_id, app_log_throughput)
    return unless @statsd

    app = BaritoApp.find_by(id: app_id)
    if app.nil?
      return
    end
    app_group = app.app_group
   
    @statsd.gauge("barito.log_count", app.log_count, tags: ["app_group:#{app_group.name}", "app_name:#{app.name}"])
    @statsd.gauge("barito.log_throughput", app_log_throughput, tags: ["app_group:#{app_group.name}", "app_name:#{app.name}"])

  end

  def app_count_changed
    return unless @statsd
    app_count = AppGroup.joins(:barito_apps, :infrastructure).where.not(infrastructures: { provisioning_status: "DELETED" }).count
    @statsd.gauge("barito.total_app",app_count)
  end

  def team_count_changed
    return unless @statsd
    team_count = AppGroup.joins(:infrastructure).where.not(infrastructures: { provisioning_status: "DELETED"}).count
    @statsd.gauge("barito.total_team",team_count)
  end
end
