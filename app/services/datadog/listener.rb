module Datadog
  class Listener
    def initialize
      @dog = Dogapi::Client.new(Figaro.env.datadog_api_key)
    end

    def log_count_changed(app_id, log_count, new_log_count)
      app = BaritoApp.find_by(id: app_id)
      log_count_per_app_group = BaritoApp.where(app_group_id: app.app_group_id).sum(&:log_count)
      if app.nil?
        return
      end

      if Figaro.env.datadog_integration == 'true'
        @dog.emit_point("barito.#{app.name}.log_count", log_count)
        @dog.emit_point("barito.#{app.app_group.name}.log_count", log_count_per_app_group)
        @dog.emit_point("barito.#{app.name}.log_throughput", new_log_count)
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
