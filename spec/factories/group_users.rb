FactoryBot.define do
  factory :group_user do
    association :group
    association :user
    association :role, factory: :app_group_role
  end
end
