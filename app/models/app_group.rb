class AppGroup < ApplicationRecord
  validates :name, :secret_key, presence: true

  has_many :barito_apps
  has_many :app_group_users
  has_many :users, through: :app_group_users
  has_one :infrastructure

  scope :active, -> {
    joins(:infrastructure).
      where.not(infrastructures: { provisioning_status:'DELETED' })
  }

  def self.setup(env, params)
    log_retention_days = nil
    log_retention_days = Figaro.env.default_log_retention_days.to_i unless Figaro.env.default_log_retention_days.blank?
    log_retention_days = params[:log_retention_days].to_i unless params[:log_retention_days].blank?

    ActiveRecord::Base.transaction do
      app_group = AppGroup.create(
        name: params[:name],
        secret_key: AppGroup.generate_key,
        log_retention_days: log_retention_days
      )
      infrastructure = Infrastructure.setup(
        env,
        name: params[:name],
        app_group_id: app_group.id,
        cluster_template_id: params[:cluster_template_id],
      )

      [app_group, infrastructure]
    end
  end

  def increase_log_count(new_count)
    update_column(:log_count, log_count + new_count.to_i)
  end

  def self.generate_key
    SecureRandom.uuid.gsub(/\-/, '')
  end

  def available?
    self.infrastructure.active?
  end

  def max_tps
    TPS_CONFIG[self.infrastructure.capacity]['max_tps']
  end
end
