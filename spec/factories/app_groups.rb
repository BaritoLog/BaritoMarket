FactoryBot.define do
  factory :app_group do
    association :user
    name Faker::Lorem.word
  end
end
