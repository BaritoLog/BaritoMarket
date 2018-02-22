Devise.setup do |config|
  require 'devise/orm/active_record'
  config.cas_base_url = "http://localhost:3001"
end
