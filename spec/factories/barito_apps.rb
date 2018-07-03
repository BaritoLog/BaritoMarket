FactoryBot.define do
  factory :barito_app do
    association     :app_group
    name            Faker::Lorem.word
    topic_name      Faker::Lorem.word.underscore
    secret_key      BaritoApp.generate_key
    status          BaritoApp.statuses[:inactive]
    max_tps         [10, 100, 1000].sample
  end
end
