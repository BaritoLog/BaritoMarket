class TpsConfig

  attr_accessor :config

  def initialize(config)
    @config = config
  end

  def all
    @config.map { |key, configs|
        [configs['name'], key]
    }
  end

  def name(id)
    config = get(id)
    unless config.nil?
      return config['name']
    end
  end

  def get(id)
    @config[id]
  end
end