module Datadog
  class Listener 
    def initialize
      @dog = Dogapi::Client.new(Figaro.env.datadog_api_key)
    end

    def log_count_changed(app_id, new_log_count)
      app = BaritoApp.find_by(id: app_id)
      if app.nil?
        return 
      end

      if Figaro.env.datadog_integration == 'true'
        @dog.emit_point("barito.#{app.name}", new_log_count)
      end
    end

    def app_count_changed(app_id, new_app_count)
      app = BaritoApp.find_by(id: app_id)
      if app.nil?
        return 
      end

      if Figaro.env.datadog_integration == 'true'
        @dog.emit_point("barito.#{app.app_group.name}", new_app_count)
      end
    end

    def team_count_changed
      if Figaro.env.datadog_integration == 'true'
        count = AppGroup.count
        @dog.emit_point("barito.total_app_group", count)
      end
    end
  end
end