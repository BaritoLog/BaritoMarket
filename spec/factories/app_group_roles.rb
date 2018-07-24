FactoryBot.define do
  factory :app_group_role do
    name 'member'

    trait :owner do
      name 'owner'
    end

    trait :admin do 
      name 'admin'
    end
  end
end
