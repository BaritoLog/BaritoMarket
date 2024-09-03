FactoryBot.define do
  factory :app_group do
    sequence(:name) { |n| "#{Faker::Cat.name} #{n}" }
    sequence(:cluster_name) { AppGroup.generate_cluster_name }
    secret_key      AppGroup.generate_key
    status         :ACTIVE

    trait :inactive do
      status :INACTIVE
    end
  end
end
