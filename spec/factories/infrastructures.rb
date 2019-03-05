FactoryBot.define do
  factory :infrastructure do
    name                  Faker::Lorem.word
    cluster_name          Rufus::Mnemo.from_i(1000)
    capacity              %w(small medium large).sample
    provisioning_status   Infrastructure.provisioning_statuses[:pending]
    status                Infrastructure.statuses[:inactive]
    consul_host           Faker::Internet.domain_name
    association           :app_group
    association           :component_template
  end
end
