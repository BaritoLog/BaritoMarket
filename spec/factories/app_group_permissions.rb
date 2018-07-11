FactoryBot.define do
  factory :app_group_permission do
    association :app_group
    association :group
  end
end
