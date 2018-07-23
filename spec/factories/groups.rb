FactoryBot.define do
  factory :group do
    sequence(:name) { |t| "group_#{t}" }
  end
end
