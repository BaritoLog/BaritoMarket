FactoryBot.define do
  factory :app_group_team do
    association :app_group
    association :role, factory: :app_group_role
    association :group
  end
end
