FactoryBot.define do
  factory :infrastructure do
    name                  Faker::Lorem.word
    cluster_name          Rufus::Mnemo.from_i(1000)
    capacity              %w(small medium large).sample
    provisioning_status   Infrastructure.provisioning_statuses[:pending]
    status                Infrastructure.statuses[:inactive]
    consul_host           Faker::Internet.domain_name
    options               { {"kafka_partition": 1, "kafka_replication_factor": 1, "max_tps": 100} }
    association           :app_group
    association           :cluster_template
  end
end
