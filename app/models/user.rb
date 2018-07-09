class User < ActiveRecord::Base
  if Figaro.env.enable_check_gate == 'true'
    devise :cas_authenticatable, :trackable
  else
    devise :database_authenticatable, :trackable, :registerable
  end

  def cas_extra_attributes=(extra_attributes)
    extra_attributes.each do |name, value|
      case name.to_sym
      when :email
        self.email = value
      end
    end
  end

  def display_name
    return username if email.blank?
    email
  end
end
