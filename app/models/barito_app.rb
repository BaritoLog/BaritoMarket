class BaritoApp < ActiveRecord::Base
  validates :name, :tps_config, :app_group, :secret_key, :cluster_name, :setup_status, :app_status, presence: true
  validates :app_group, inclusion: { in: Figaro.env.app_groups.split(',').map(&:downcase) }
  validate  :tps_config_valid_key?

  enum app_statuses: {
    inactive: 'INACTIVE',
    active: 'ACTIVE',
  }
  enum setup_statuses: {
    pending: 'PENDING',
    blueprint_creation: 'BLUEPRINT_CREATION',
    blueprint_creation_error: 'BLUEPRINT_CREATION_ERROR',
    blueprint_executed: 'BLUEPRINT_EXECUTED',
    blueprint_executed_error: 'BLUEPRINT_EXECUTED_ERROR',
    provisioning_stated: 'PROVISIONING_STARTED',
    provisioning_error: 'PROVISIONING_ERROR',
    chef_bootstrap_started: 'CHEF_BOOTSTRAP_STARTED',
    chef_bootstrap_error: 'CHEF_BOOTSTRAP_ERROR',
    finished: 'FINISHED',
  }

  def self.setup(name, tps_config, app_group)
    barito_app = BaritoApp.new(
      name:         name,
      tps_config:   tps_config,
      app_group:    app_group,
      secret_key:   SecureRandom.uuid.gsub(/\-/,''),
      cluster_name: Rufus::Mnemo.from_i(BaritoApp.generate_cluster_index),
      app_status:   BaritoApp.app_statuses[:inactive],
      setup_status: BaritoApp.setup_statuses[:pending],
    )

    if barito_app.valid?
      barito_app.save
      blueprint = Blueprint.new(barito_app, Rails.env)
      blueprint_path = blueprint.generate_file(barito_app)
      BlueprintWorker.perform_async(blueprint_path)
    end

    barito_app
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

  def increase_log_count(new_count)
    self.update_column(:log_count, self.log_count + new_count.to_i)
  end

  def self.generate_cluster_index
    BaritoApp.all.size + 1
  end

  def self.secret_key_valid?(token)
    BaritoApp.find_by_secret_key(token).present?
  end
end
