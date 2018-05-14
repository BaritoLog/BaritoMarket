class ChefConfigs

  attr_accessor :config

  def initialize(config)
    @config = config
  end

  def get(instance_name)
    @config[instance_name]
  end
end