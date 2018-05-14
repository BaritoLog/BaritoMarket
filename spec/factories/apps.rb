FactoryBot.define do
  factory :app do
    name "app1"
    setup_status "PENDING"
    app_status "INACTIVE"
    tps_config_id "small"
    cluster_name "some"

    app_group
  end
end
