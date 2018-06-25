class BaritoApp < ActiveRecord::Base
  CLUSTER_NAME_PADDING = 1000
  validates :app_group, :name, :topic_name, :secret_key, :status,
    presence: true

  belongs_to :app_group

  enum statuses: {
    inactive: 'INACTIVE',
    active: 'ACTIVE',
  }

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

  def self.secret_key_valid?(token)
    BaritoApp.find_by_secret_key(token).present?
  end

  def self.generate_key
    SecureRandom.uuid.gsub(/\-/, '')
  end
end
