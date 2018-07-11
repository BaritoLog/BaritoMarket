FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user_#{n}" }
    sequence(:email) { |n| "email#{n}@example.com" }
    sequence(:auth_token) { |n| SecureRandom.hex }

    trait :admin do
      admin true
    end
  end
end
