class TpsConfig
  def self.all
    TPS_CONFIG.map { |key, configs|
        [configs['name'], key]
    }
  end

  def self.name(id)
    config = TPS_CONFIG[id]
    unless config.nil?
      return config['name']
    end
  end
end