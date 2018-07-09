FactoryBot.define do
  factory :app_group do
    association :created_by, factory: :user
    name Faker::Lorem.word
  end
end
