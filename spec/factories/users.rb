FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user_#{n}" }
  end
end
