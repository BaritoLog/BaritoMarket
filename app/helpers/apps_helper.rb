module AppsHelper
  def status(app)
    if app.app_status.eql?(BaritoApp.app_statuses[:inactive])
      app.setup_status
    else
      app.app_status
    end
  end

  def inactive?(app)
    app.app_status.eql?(BaritoApp.app_statuses[:inactive])
  end

  def tps_size(app)
    config = YAML.load_file("#{Rails.root}/config/tps_config.yml")[Rails.env]
    config[app.tps_config]['tps_limit']
  end

  def tps_name(app)
    config = YAML.load_file("#{Rails.root}/config/tps_config.yml")[Rails.env]
    config[app.tps_config]['name']
  end
end
