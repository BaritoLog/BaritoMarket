FactoryBot.define do
  factory :helm_infrastructure do
    association :app_group
    association :helm_cluster_template
    override_values { {} }
    last_log "MyText"
  end
end
