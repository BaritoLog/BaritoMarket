FactoryBot.define do
  factory :barito_app do
    name            Faker::Lorem.word
    app_group       Figaro.env.app_groups.split(',').map(&:downcase).sample
    setup_status    BaritoApp.setup_statuses[:pending]
    secret_key      SecureRandom.uuid.gsub(/\-/, '')
    app_status      BaritoApp.app_statuses[:inactive]
    tps_config      %w(small medium large).sample
    cluster_name    Rufus::Mnemo.from_i(1000)
  end
end
