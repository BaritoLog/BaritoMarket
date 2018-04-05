require 'securerandom'

class User < ActiveRecord::Base
  acts_as_paranoid
  devise :cas_authenticatable

  def cas_extra_attributes=(extra_attributes)
    logger.debug "Received extra attributes: #{extra_attributes.inspect}"
    extra_attributes.each do |name, value|
      case name.to_sym
        when :email
          self.email = value
        when :fullname
          self.fullname = value
      end
    end
  end

  def self.authenticate_cas encoded_string
    username_password = Base64.decode64 encoded_string.split(" ")[1]
    username = username_password.split(':').first
    password = username_password.split(':').last

    if User.find_and_check_user username, password
      return username
    else
      return nil
    end
  end

  def self.get_user username
    return User.where(username: username).first
  end

  def self.find_and_check_user username, token
    user = User.get_user username
    return false if user.blank?
    
    user_key = "#{user.id}:#{Time.now.hour}"
    token == SecureRandom.base64
  end
end
