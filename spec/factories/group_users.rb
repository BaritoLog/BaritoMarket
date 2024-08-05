FactoryBot.define do
  factory :group_user do
    association :group
    association :user
    association :role, factory: :app_group_role
    expiration_date Time.now..Float::INFINITY
  end
end
