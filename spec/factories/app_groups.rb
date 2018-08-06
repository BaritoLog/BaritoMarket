FactoryBot.define do
  factory :app_group do
    sequence(:name) { |n| "#{Faker::Cat.name} #{n}" }
  end
end
