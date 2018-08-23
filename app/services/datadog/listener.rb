module Datadog
  class Listener
    def initialize
      @dog = Dogapi::Client.new(Figaro.env.datadog_api_key)
    end

    def log_count_changed(app_id, app_log_throughput)
      app = BaritoApp.find_by(id: app_id)
      if app.nil?
        return
      end
      app_group = app.app_group

      if Figaro.env.datadog_integration == 'true'
        @dog.batch_metrics do
          @dog.emit_point("barito.#{app.name}.log_count", app.log_count)
          @dog.emit_point("barito.#{app_group.name}.log_count", app_group.log_count)
          @dog.emit_point("barito.#{app.name}.log_throughput", app_log_throughput)
        end
      end
    end

    def app_count_changed
      if Figaro.env.datadog_integration == 'true'
        count = BaritoApp.count
        @dog.emit_point("barito.total_app", count)
      end
    end

    def team_count_changed
      if Figaro.env.datadog_integration == 'true'
        count = AppGroup.count
        @dog.emit_point("barito.total_team", count)
      end
    end
  end
end
