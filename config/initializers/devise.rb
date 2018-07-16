# frozen_string_literal: true

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  require 'devise/orm/active_record'

  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 11
  config.sign_out_via = :delete

  # ==> CAS configuration
  config.cas_base_url = Figaro.env.cas_base_url
  # you can override these if you need to, but cas_base_url is usually enough
  # config.cas_login_url = "https://cas.myorganization.com/login"
  # config.cas_logout_url = "https://cas.myorganization.com/logout"
  # config.cas_validate_url = "https://cas.myorganization.com/serviceValidate"

  # The CAS specification allows for the passing of a follow URL to be displayed when
  # a user logs out on the CAS server. RubyCAS-Server also supports redirecting to a
  # URL via the destination param. Set either of these urls and specify either nil,
  # 'destination' or 'follow' as the logout_url_param. If the urls are blank but
  # logout_url_param is set, a default will be detected for the service.
  # config.cas_destination_url = 'https://cas.myorganization.com'
  # config.cas_follow_url = 'https://cas.myorganization.com'
  # config.cas_logout_url_param = nil

  # You can specify the name of the destination argument with the following option.
  # e.g. the following option will change it from 'destination' to 'url'
  # config.cas_destination_logout_param_name = 'url'

  # By default, devise_cas_authenticatable will create users.  If you would rather
  # require user records to already exist locally before they can authenticate via
  # CAS, uncomment the following line.
  # config.cas_create_user = false

  # You can enable Single Sign Out, which by default is disabled.
  # config.cas_enable_single_sign_out = true

  # If you don't want to use the username returned from your CAS server as the unique
  # identifier, but some other field passed in cas_extra_attributes, you can specify
  # the field name here.
  # config.cas_user_identifier = nil

  # If you want to use the Devise Timeoutable module with single sign out,
  # uncommenting this will redirect timeouts to the logout url, so that the CAS can
  # take care of signing out the other serviced applocations. Note that each
  # application manages timeouts independently, so one application timing out will
  # kill the session on all applications serviced by the CAS.
  # config.warden do |manager|
  #   manager.failure_app = DeviseCasAuthenticatable::SingleSignOut::WardenFailureApp
  # end

  # You can also set another single sign out strategy so that you won't be attached to rails_cache.
  # Be aware that to do so you also need to set the session_store.
  # Example for setting redis_cache.
  # There are some gems the help with it. One of them is called redis-rails and it can easily be set like this:
  # Rails.application.config.session_store :redis_store, servers: ["redis://localhost:6379/0/session"]
  # This is specially useful when you need to share session id accross apps (i.e. in a distributed environment)
  # config.cas_single_sign_out_mapping_strategy = :redis_cache

  # If you need to specify some extra configs for rubycas-client, you can do this via:
  # config.cas_client_config_options = {
  #   extra_attributes_session_key: :cas_extra_attributes
  # }
end
