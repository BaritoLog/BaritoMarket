class AppGroup < ApplicationRecord
  validates :name, :secret_key, presence: true

  has_many :barito_apps
  has_many :app_group_users
  has_many :users, through: :app_group_users
  has_one :infrastructure

  scope :active, -> {
    includes(:infrastructure).
    includes(:barito_apps).
      where.not(infrastructures: { provisioning_status:'DELETED' })
  }

  def self.setup(params)
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
    self.infrastructure.options['max_tps'].to_i
  end

  def new_total_tps(diff_tps)
    self.barito_apps.sum(:max_tps)+diff_tps
  end
end
