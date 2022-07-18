# frozen_string_literal: true

OmniAuth.config.allowed_request_methods = %i[get]

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  require 'devise/orm/active_record'

  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 11
  config.sign_out_via = :delete

  config.omniauth :google_oauth2, Figaro.env.GOOGLE_CLIENT_ID, Figaro.env.GOOGLE_CLIENT_SECRET, { access_type: "offline", approval_prompt: "" }

end
