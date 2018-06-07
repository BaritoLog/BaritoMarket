FactoryBot.define do
  factory :barito_app do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    app_group       Figaro.env.app_groups.split(',').map(&:downcase).sample
    setup_status    BaritoApp.setup_statuses[:pending]
    secret_key      BaritoApp.generate_key
    app_status      BaritoApp.app_statuses[:inactive]
    tps_config      %w(small medium large).sample
    cluster_name    Rufus::Mnemo.from_i(1000)
    consul_host     Faker::Internet.domain_name

    trait :invalid do
      name nil
      app_group nil
      tps_config nil
    end
  end
end
