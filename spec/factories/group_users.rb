FactoryBot.define do
  factory :group_user do
    association :group
    association :user
  end
end
