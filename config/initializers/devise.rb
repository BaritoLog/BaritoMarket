Devise.setup do |config|
  require 'devise/orm/active_record'
  config.cas_base_url = Figaro.env.cas_base_url
end
