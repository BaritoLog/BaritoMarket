FactoryBot.define do
  factory :infrastructure_location do
    sequence(:name) { |n| "#{Faker::Cat.name} #{n}" }
    is_active { true }
    destination_server { '' }
    kibana_address_format { 'http://%s-kibana.barito' }
    producer_address_format { 'http://%s-producer.barito' }

    trait :inactive do
      is_active false
    end
  end
end
