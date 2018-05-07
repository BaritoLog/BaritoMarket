class App < ActiveRecord::Base
  extend Enumerize
  validates_presence_of :name

  enumerize :app_status, in:  %w(INACTIVE ACTIVE)
  enumerize :setup_status, in: %w(
    PENDING
    BLUEPRINT_CREATION
    BLUEPRINT_CREATION_ERROR
    BLUEPRINT_EXECUTED
    BLUEPRINT_EXECUTED_ERROR
    PROVISIONING_STARTED
    PROVISIONING_ERROR
    CHEF_BOOTSTRAP_STARTED
    CHEF_BOOTSTRAP_ERROR
    FINISHED
  )

  belongs_to :app_group, required: true
  belongs_to :log_template, required: true
  
  after_create :generate_secret_key, :generate_receiver_end_point, :generate_kibana_address, :set_setup_status_pending, :set_app_status_inactive
  
  def generate_secret_key
    update_column(:secret_key, SecureRandom.base64)
  end
  
  def generate_receiver_end_point
    update_column(:receiver_end_point, 'http://dummy.end-point/')
  end
  
  def generate_kibana_address
    update_column(:kibana_address, 'http://dummy.kibana-address/')
  end

  def set_setup_status_pending
    set_setup_status('PENDING')
  end

  def set_app_status_inactive
    set_app_status('INACTIVE')
  end

  private

  def set_setup_status(status)
    self.setup_status=status
  end

  def set_app_status(status)
    self.app_status=status
  end

end
