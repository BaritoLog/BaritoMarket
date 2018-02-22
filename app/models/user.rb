class User < ActiveRecord::Base
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
end
