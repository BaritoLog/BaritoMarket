module Datadog
  class Listener
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
        @dog.emit_point("barito.#{app.name}.log_count", app.log_count)
        @dog.emit_point(
          "barito.#{app_group.name}.log_count", app_group.log_count)
        @dog.emit_point(
          "barito.#{app.name}.log_throughput", app_log_throughput)
      end
    end

    def app_count_changed
      return unless @dog
      count = BaritoApp.count
      @dog.emit_point("barito.total_app", count)
    end

    def team_count_changed
      return unless @dog
      count = AppGroup.count
      @dog.emit_point("barito.total_team", count)
    end
  end
end
