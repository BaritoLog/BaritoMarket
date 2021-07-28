FactoryBot.define do
  factory :helm_cluster_template do
    sequence(:name) { Faker::Lorem.word }
    values { { 'key' => Faker::Lorem.word } }
    max_tps 1
  end
end
