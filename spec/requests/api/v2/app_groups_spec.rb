require 'rails_helper'

RSpec.describe 'App Groups API', type: :request do
  let(:headers) do
    { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
  end

  before(:all) do
    @access_token = 'ABC123'
    @ext_app = create(:ext_app, access_token: @access_token)
  end

  after(:all) do
    @ext_app.destroy
  end


  describe 'App Group API' do
    it 'should return app group information' do
      app_group = create(:app_group)
      helm_cluster_template = create(:helm_cluster_template)

      post api_v2_create_app_group_path, params: { access_token: @access_token, name: app_group.name, cluster_template_id: helm_cluster_template.id }, headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response['data']['name']).to eq(app_group.name)
    end

    it 'when appgroup secret is not provided it should return 422' do
      error_msg = 'Invalid Params: app_group_secret is a required parameter'
      get api_v2_check_app_group_path, params: { access_token: @access_token, app_group_secret: '', app_name: "test-app-01" }, headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response['code']).to eq(422)
      expect(json_response['errors']).to eq([error_msg])
    end

    it 'should return app status information' do
      app_group = create(:app_group)
      create(:helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active])
      app = create(:barito_app, app_group: app_group, name: "test-app-01", status: BaritoApp.statuses[:active])

      get api_v2_check_app_group_path, params: { access_token: @access_token, app_group_secret: app_group.secret_key, app_name: "test-app-01" }, headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response.key?('provisioning_status')).to eq(true)
      expect(json_response['status']).to eq "ACTIVE"
    end

    it 'should return helm cluster template' do
      helm_cluster_template = create(:helm_cluster_template)
      get api_v2_cluster_templates_path, params: { access_token: @access_token}, headers: headers

      json_response = JSON.parse(response.body)
      expected_result = [{"id"=>helm_cluster_template.id, "name"=>"#{helm_cluster_template.name}"}]
      expect(json_response).to eq expected_result
    end
  end

  describe 'Profile app' do
    it 'should return list profile information of registered Barito apps inside an appgroup when override values of replication and log retention are defined' do
      AppGroup.delete_all
      BaritoApp.delete_all
      default_prod_replication_factor = 2
      kafka_count = 2
      elasticsearch_count = 3

      app_group = create(:app_group)

      override_values = {
        "kafka" => {
          "count": kafka_count,
        },
        "elasticsearch" => {
          "count": elasticsearch_count,
        }
      }
      helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        cluster_name: "test",
        status: HelmInfrastructure.statuses[:active],
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished],
        override_values: override_values
      )
      app1 = create(:barito_app, app_group: app_group, topic_name: "topic1", name: "test-app-1", status: BaritoApp.statuses[:active])
      app2 = create(:barito_app, app_group: app_group, topic_name: "topic2", name: "test-app-2", status: BaritoApp.statuses[:active])

      get api_v2_profile_app_path,
        params: { access_token: @access_token},
        headers: headers

      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)

      expect(json_response.length).to eq(1)
      j = json_response[0]

      expect(j['app_group_name']).to eq(helm_infrastructure.app_group_name)
      expect(j['app_group_cluster_name']).to eq(helm_infrastructure.cluster_name)
      expect(j['app_group_replication_factor']).to eq(default_prod_replication_factor)

      expect(j['app_group_barito_apps'][0]['app_name']).to eq(app1.name)
      expect(j['app_group_barito_apps'][0]['app_log_retention']).to eq(app1.log_retention_days)

      expect(j['app_group_barito_apps'][1]['app_name']).to eq(app2.name)
      expect(j['app_group_barito_apps'][1]['app_log_retention']).to eq(app2.log_retention_days)
    end

    it 'should return list profile information of registered Barito apps inside an appgroup when override values of replication and log retention are not defined' do
      AppGroup.delete_all
      BaritoApp.delete_all
      default_prod_replication_factor = 2
      default_prod_elasticsearch_count = 3
      default_prod_log_retention_days = 14

      app_group = create(:app_group)

      override_values = {
        "kafka" => {
          "storage" => {
            "size": "24Gi"
          },
        },
        "elasticsearch" => {
          "storage" => {
            "size": "24Gi"
          },
        }
      }
      helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        cluster_name: "test",
        status: HelmInfrastructure.statuses[:active],
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished],
        override_values: override_values
      )
      app1 = create(:barito_app, app_group: app_group, topic_name: "topic1", name: "test-app-1", status: BaritoApp.statuses[:active], log_retention_days: nil)
      app2 = create(:barito_app, app_group: app_group, topic_name: "topic2", name: "test-app-2", status: BaritoApp.statuses[:active], log_retention_days: nil)

      get api_v2_profile_app_path,
        params: { access_token: @access_token},
        headers: headers

      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)

      expect(json_response.length).to eq(1)
      j = json_response[0]

      expect(j['app_group_name']).to eq(helm_infrastructure.app_group_name)
      expect(j['app_group_cluster_name']).to eq(helm_infrastructure.cluster_name)
      expect(j['app_group_replication_factor']).to eq(default_prod_replication_factor)

      expect(j['app_group_barito_apps'][0]['app_name']).to eq(app1.name)
      expect(j['app_group_barito_apps'][0]['app_log_retention']).to eq(default_prod_log_retention_days)

      expect(j['app_group_barito_apps'][1]['app_name']).to eq(app2.name)
      expect(j['app_group_barito_apps'][1]['app_log_retention']).to eq(default_prod_log_retention_days)
    end
  end

  describe 'Update latest cost' do
    it 'should return fail update status when wrong access token is provided' do
      AppGroup.delete_all
      BaritoApp.delete_all

      app_group = create(:app_group)
      app1 = create(:barito_app, app_group: app_group, topic_name: "topic1", name: "test-app-1", status: BaritoApp.statuses[:active])
      app2 = create(:barito_app, app_group: app_group, topic_name: "topic2", name: "test-app-2", status: BaritoApp.statuses[:active])

      patch api_v2_update_cost_path,
        params: {
          access_token: "wrong access token",
          data: [
            {
              id: "40afaf60-ccab-4d33-90e5-72f78bd6f8ae",
              created_at: "2023-02-23T17:38:08.400645+07:00",
              app_group_name: app_group.name,
              app_group_cluster_name: "test",
              app_group_replication_factor: 5,
              app_name: app1.name,
              app_log_retention: 14,
              app_log_bytes: 30000,
              calculation_price: 90003920,
              calculation_log_retention_standard: 14,
              calculation_replication_factor_standard: 5,
              calculation_log_ingestion_mode: "PRODUCER",
              calculation_replication_factor_mode: "BOTH",
            },
            {
              id: "40afaf60-ccab-4d33-90e5-72f78bd6f8ae",
              created_at: "2023-02-23T17:38:08.400645+07:00",
              app_group_name: app_group.name,
              app_group_cluster_name: "test",
              app_group_replication_factor: 5,
              app_name: app2.name,
              app_log_retention: 14,
              app_log_bytes: 59182930,
              calculation_price: 273810589,
              calculation_log_retention_standard: 14,
              calculation_replication_factor_standard: 5,
              calculation_log_ingestion_mode: "PRODUCER",
              calculation_replication_factor_mode: "BOTH",
            }
          ]
        }, headers: headers
      expect(response.status).to eq 401
    end

    it 'should return success update status when all params are correctly provided' do
      AppGroup.delete_all
      BaritoApp.delete_all

      app_group = create(:app_group)
      helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        cluster_name: "test",
        status: HelmInfrastructure.statuses[:active],
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished]
      )
      app1 = create(:barito_app, app_group: app_group, topic_name: "topic1", name: "test-app-1", status: BaritoApp.statuses[:active])
      app2 = create(:barito_app, app_group: app_group, topic_name: "topic2", name: "test-app-2", status: BaritoApp.statuses[:active])

      patch api_v2_update_cost_path,
        params: {
          access_token: @access_token,
          data: [
            {
              id: "40afaf60-ccab-4d33-90e5-72f78bd6f8ae",
              created_at: "2023-02-23T17:38:08.400645+07:00",
              app_group_name: app_group.name,
              app_group_cluster_name: "test",
              app_group_replication_factor: 5,
              app_name: app1.name,
              app_log_retention: 14,
              app_log_bytes: 30000,
              calculation_price: 90003920,
              calculation_log_retention_standard: 14,
              calculation_replication_factor_standard: 5,
              calculation_log_ingestion_mode: "PRODUCER",
              calculation_replication_factor_mode: "BOTH",
            },
            {
              id: "40afaf60-ccab-4d33-90e5-72f78bd6f8ae",
              created_at: "2023-02-23T17:38:08.400645+07:00",
              app_group_name: app_group.name,
              app_group_cluster_name: "test",
              app_group_replication_factor: 5,
              app_name: app2.name,
              app_log_retention: 14,
              app_log_bytes: 59182930,
              calculation_price: 273810589,
              calculation_log_retention_standard: 14,
              calculation_replication_factor_standard: 5,
              calculation_log_ingestion_mode: "PRODUCER",
              calculation_replication_factor_mode: "BOTH",
            }
          ]
        }, headers: headers
      expect(response.status).to eq 200

      json_response = JSON.parse(response.body)

      expect(json_response['success']).to eq(true)
      expect(json_response['affected_app']).to eq(2)
    end
  end
end
