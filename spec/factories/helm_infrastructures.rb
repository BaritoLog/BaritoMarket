FactoryBot.define do
  factory :helm_infrastructure do
    association :app_group
    association :helm_cluster_template
    association :infrastructure_location, factory: :infrastructure_location
    override_values { {} }
    last_log "MyText"
    #sequence(:cluster_name) { Rufus::Mnemo.from_integer(HelmInfrastructure.generate_cluster_index) }
    cluster_name { |helm_infrastructure| helm_infrastructure.app_group.cluster_name }
    provisioning_status   HelmInfrastructure.provisioning_statuses[:pending]
    status                HelmInfrastructure.statuses[:inactive]
    max_tps         [10, 100, 1000].sample
    is_active       true
    use_k8s_kibana  true

    trait :active do
      status HelmInfrastructure.statuses[:active]
      provisioning_status HelmInfrastructure.provisioning_statuses[:finished]
    end
  end
end
