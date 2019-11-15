require 'prometheus/client'

class PrometheusListener
  def initialize(registry = Prometheus::Client.registry)
    @log_count_metric = registry.gauge(
      :barito_market_log_count, docstring: 'Count of consumed logs', labels: %i[app_group app_name]
    )
    @log_throughput_metric = registry.gauge(
      :barito_market_log_throughput, docstring: 'Log throughput', labels: %i[app_group app_name]
    )
    @app_count_metric = registry.gauge(
      :barito_market_app_count, docstring: 'Count of registered applications'
    )
    @team_count_metric = registry.gauge(
      :barito_market_team_count, docstring: 'Count of teams'
    )
  end

  def log_count_changed(app_id, app_log_throughput)
    app = BaritoApp.find_by(id: app_id)
    if app.nil?
      return
    end

    app_group = app.app_group
    app_name = app.name

    @log_count_metric.set(app.log_count, labels: { app_group: app_group.name, app_name: app_name })
    @log_throughput_metric.set(
      app_log_throughput, labels: { app_group: app_group.name, app_name: app_name }
    )
  end

  def app_count_changed
    app_count = AppGroup.joins(:barito_apps, :infrastructure).where.not(
      infrastructures: { provisioning_status: 'DELETED' },
    ).count
    @app_count_metric.set(app_count)
  end

  def team_count_changed
    team_count = AppGroup.joins(:infrastructure).where.not(
      infrastructures: { provisioning_status: 'DELETED' },
    ).count
    @team_count_metric.set(team_count)
  end
end
