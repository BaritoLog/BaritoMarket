class BaritoApp < ApplicationRecord
  CLUSTER_NAME_PADDING = 1000
  NAME_FORMAT         = /\A(?![\_\- ])[\p{Alpha}\d\_\- ]+(?<![\_\- ])\z/
  TOPIC_NAME_FORMAT   = /\A(?![\_\-])[\p{Alpha}\d\_\-]+(?<![\_\-])\z/

  validates :app_group, :name, :topic_name, :secret_key, :status,
    presence: true
  validates :name, format: { with: NAME_FORMAT }
  validates :topic_name, format: { with: TOPIC_NAME_FORMAT }

  before_save { topic_name.downcase! }

  belongs_to :app_group

  enum statuses: {
    inactive: 'INACTIVE',
    active: 'ACTIVE',
  }

  def self.setup(app_params)
    app = BaritoApp.create(
      app_group_id: app_params[:app_group_id],
      name: app_params[:name],
      topic_name: app_params[:topic_name].gsub(/ /, '-'),
      secret_key: BaritoApp.generate_key,
      max_tps: app_params[:max_tps].to_i,
      status: BaritoApp.statuses[:active],
    )
    app
  end

  def active?
    status == BaritoApp.statuses[:active]
  end

  def available?
    active? && app_group.infrastructure.active?
  end

  def update_status(status)
    status = status.downcase.to_sym
    if BaritoApp.statuses.key?(status)
      update_attribute(:status, BaritoApp.statuses[status])
    else
      false
    end
  end

  def increase_log_count(new_count)
    update_column(:log_count, log_count + new_count.to_i)
  end

  def self.secret_key_valid?(secret_key)
    BaritoApp.find_by_secret_key(secret_key).present?
  end

  def self.generate_key
    SecureRandom.uuid.gsub(/\-/, '')
  end

  def app_group_name
    app_group&.name
  end

  def cluster_name
    app_group&.infrastructure&.cluster_name
  end

  def consul_host
    app_group&.infrastructure&.consul_host
  end
end
