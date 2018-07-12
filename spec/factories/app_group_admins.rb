FactoryBot.define do
  factory :app_group_admin do
    association :app_group
    association :user
  end
end
