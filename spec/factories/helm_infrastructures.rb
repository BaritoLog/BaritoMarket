FactoryBot.define do
  factory :helm_infrastructure do
    association :app_group
    association :helm_cluster_template
    override_values { {} }
    last_log "MyText"
    sequence(:cluster_name) { Rufus::Mnemo.from_integer(HelmInfrastructure.generate_cluster_index) }
    provisioning_status   HelmInfrastructure.provisioning_statuses[:pending]
    status                HelmInfrastructure.statuses[:inactive]
    max_tps         [10, 100, 1000].sample
    is_active       true
    use_k8s_kibana  true
  end
end
