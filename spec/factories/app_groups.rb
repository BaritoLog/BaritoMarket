FactoryBot.define do
  factory :app_group do
    sequence(:name) { |n| "#{Faker::Cat.name} #{n}" }
    secret_key      AppGroup.generate_key
  end
end
