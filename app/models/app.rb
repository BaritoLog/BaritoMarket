class App < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :app_group, required: true
  belongs_to :log_template, required: true
  
  after_create :generate_secret_key, :generate_receiver_end_point, :generate_kibana_address
  
  def generate_secret_key
    update_column(:secret_key, SecureRandom.base64)
  end
  
  def generate_receiver_end_point
    update_column(:receiver_end_point, 'http://dummy.end-point/')
  end
  
  def generate_kibana_address
    update_column(:kibana_address, 'http://dummy.kibana-address/')
  end
  
end
