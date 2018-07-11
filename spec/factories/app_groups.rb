FactoryBot.define do
  factory :app_group do
    association :created_by, factory: :user
    sequence(:name) { |n| "#{Faker::Cat.name} #{n}" }
  end
end
