class PrometheusListener
  def initialize(registry)
    @log_count_metric = registry.gauge(
      :barito_market_log_count, docstring: 'Count of consumed logs'
    )
  end
end
