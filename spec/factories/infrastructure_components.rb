FactoryBot.define do
  factory :infrastructure_component do
    association     :infrastructure
    hostname        Faker::Lorem.word
    category        Faker::Lorem.word.underscore
    image           Faker::Lorem.word
    message         Faker::Lorem.sentence
    status          InfrastructureComponent.statuses[:pending]

    sequence(:sequence, (1..10).cycle){ |n| n}
  end
end
