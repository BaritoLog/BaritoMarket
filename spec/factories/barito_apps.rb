FactoryBot.define do
  factory :barito_app do
    association     :app_group
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    topic_name      Faker::Lorem.word.underscore
    secret_key      BaritoApp.generate_key
    status          BaritoApp.statuses[:inactive]
    max_tps         [10, 100, 1000].sample
    log_retention_days         [10, 100, 1000].sample

    trait :invalid do
      name nil
    end
  end
end
