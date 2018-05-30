class BaritoApp < ActiveRecord::Base
  validates :name, :tps_config, :app_group, :secret_key, :cluster_name, :setup_status,
            :app_status, presence: true
  validates :app_group, inclusion: { in: Figaro.env.app_groups.split(',').map(&:downcase) }
  validate  :tps_config_valid_key?

  enum app_status: { inactive: 'INACTIVE', active: 'ACTIVE' }
  enum setup_status: {
    pending: 'PENDING',
    blueprint_creation: 'BLUEPRINT_CREATION',
    blueprint_creation_error: 'BLUEPRINT_CREATION_ERROR',
    blueprint_executed: 'BLUEPRINT_EXECUTED',
    blueprint_exected_error: 'BLUEPRINT_EXECUTED_ERROR',
    provisioning_stated: 'PROVISIONING_STARTED',
    provisioning_error: 'PROVISIONING_ERROR',
    chef_bootstrap_started: 'CHEF_BOOTSTRAP_STARTED',
    chef_bootstrap_error: 'CHEF_BOOTSTRAP_ERROR',
    finished: 'FINISHED',
  }

  def self.setup(name, tps_config, app_group)
    app = BaritoApp.new(name: name, tps_config: tps_config, app_group: app_group) do |instance|
      instance.secret_key = SecureRandom.base64
      instance.cluster_name = Rufus::Mnemo.from_i(BaritoApp.generate_cluster_index)
      instance.setup_status = BaritoApp.setup_statuses[:pending]
      instance.app_status = BaritoApp.app_statuses[:inactive]
    end
    if app.valid?
      app.save
      blueprint = Blueprint.new(app, Rails.env)
      blueprint_path = blueprint.generate_file(app)
      BlueprintWorker.perform_async(blueprint_path)
    end
    app
  end

  def update_app_status(status)
    if BaritoApp.app_statuses.key?(status.downcase.to_sym)
      update_attribute(:app_status, BaritoApp.app_statuses[status.to_sym])
    else
      false
    end
  end

  def update_setup_status(status)
    if BaritoApp.setup_statuses.key?(status.downcase.to_sym)
      update_attribute(:setup_status, BaritoApp.setup_statuses[status.to_sym])
    else
      false
    end
  end

  def tps_config_valid_key?
    config = YAML.load_file("#{Rails.root}/config/tps_config.yml")[Rails.env]
    config_types = config.keys.map(&:downcase)
    errors.add(:tps_config, 'Invalid Config Value') unless config_types.include?(tps_config)
  end

  def self.generate_cluster_index
    BaritoApp.all.size + 1
  end
end
