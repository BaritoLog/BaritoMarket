require 'rails_helper'

RSpec.describe 'Deactivated App Group by Cluster Name', type: :request do
  let(:headers) do
    { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
  end

  before(:all) do
    @access_token = 'ABCDE'
    @ext_app = create(:ext_app, access_token: @access_token)
  end

  describe 'Deactivated App Group by Cluster Name' do
    it 'should deactivated the app group' do
      # Create a App Group
      app_group = create(:app_group)
      helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        cluster_name: "test-delete",
        status: HelmInfrastructure.statuses[:active],
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished]
      )

      # Send a DELETE request to the delete action
      post api_v2_deactivated_by_cluster_name_path(cluster_name: helm_infrastructure.cluster_name, app_group_name: app_group.name), params:{access_token: @access_token}, headers: headers

      # Expect a successful response
      expect(response.status).to eq(200)

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Expect the response to indicate success
      expect(json_response['success']).to eq(true)
      expect(json_response['message']).to eq('App Group deactivated successfully')

      # Verify that the Helm Infrastructure has been deleted
      expect(HelmInfrastructure.find_by(cluster_name: helm_infrastructure.cluster_name).provisioning_status).to eq('DELETE_STARTED')
    end
    it 'should return 400 if cluster_name or app_group_name is missing' do
      # Send a DELETE request without providing cluster_name or app_group_name
      post api_v2_deactivated_by_cluster_name_path, params: { access_token: @access_token }, headers: headers

      # Expect a 400 response
      expect(response.status).to eq(400)

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Expect the response to indicate failure and the reason
      expect(json_response['success']).to eq(false)
      expect(json_response['errors']).to eq(['Both cluster_name and app_group_name are required'])
    end
    it 'should return 400 if app_group_name does not match cluster_name' do
      # Create a App Group
      app_group = create(:app_group)
      helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        cluster_name: "test-delete",
        status: HelmInfrastructure.statuses[:active],
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished]
      )
      # Send a DELETE request to the deactivated_by_cluster_name action
      post api_v2_deactivated_by_cluster_name_path( cluster_name: helm_infrastructure.cluster_name, app_group_name: 'mismatch_group'), params:{access_token: @access_token}, headers: headers
      # Expect a 404 response
      expect(response.status).to eq(404)

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Expect the response to indicate failure and the reason
      expect(json_response['success']).to eq(false)
      expect(json_response['errors']).to eq(['Helm Infrastructure not found'])
    end

    it 'should return 404 if Helm Infrastructure is not found' do
      # Send a DELETE request to the delete action with an invalid ID
      post api_v2_deactivated_by_cluster_name_path(cluster_name: 'nonexistent_cluster', app_group_name: 'nonexistent_group'), params:{access_token: @access_token}, headers: headers

      # Expect a 404 response
      expect(response.status).to eq(404)

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Expect the response to indicate failure and the reason
      expect(json_response['success']).to eq(false)
      expect(json_response['errors']).to eq(['Helm Infrastructure not found'])
    end

    it 'should return 404 if Helm Infrastructure is not active' do
      # Create a Helm Infrastructure but set it to inactive
      helm_infrastructure = create(:helm_infrastructure, status: HelmInfrastructure.statuses[:inactive])

      # Send a DELETE request to the delete action
      post api_v2_deactivated_by_cluster_name_path(cluster_name: helm_infrastructure.cluster_name, app_group_name: 'nonexistent_group'),params:{access_token: @access_token}, headers: headers

      # Expect a 404 response
      expect(response.status).to eq(404)

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Expect the response to indicate failure and the reason
      expect(json_response['success']).to eq(false)
      expect(json_response['errors']).to eq(['Helm Infrastructure not found'])
    end
  end
end
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
    it 'should return list profile information of all Barito apps inside an appgroup when default log retention values of apps are used' do
      AppGroup.delete_all
      BaritoApp.delete_all
      default_prod_replication_factor = 2

      app_group = create(:app_group)

      helm_cluster_template = create(
        :helm_cluster_template,
        name: "Production - 2xLarge - 256 - 384"
      )

      helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        cluster_name: "test",
        helm_cluster_template: helm_cluster_template,
        status: HelmInfrastructure.statuses[:active],
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished]
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

    it 'should return list profile information of all Barito apps having appgroup\'s log retention days when default log retention values of apps are not used' do
      AppGroup.delete_all
      BaritoApp.delete_all
      default_staging_replication_factor = 1
      default_app_group_log_retention_days = Figaro.env.DEFAULT_LOG_RETENTION_DAYS.to_i

      app_group = create(:app_group)

      helm_cluster_template = create(
        :helm_cluster_template,
        name: "Staging - 2xLarge - 256 - 384"
      )

      helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        cluster_name: "test",
        helm_cluster_template: helm_cluster_template,
        status: HelmInfrastructure.statuses[:active],
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished],
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
      expect(j['app_group_replication_factor']).to eq(default_staging_replication_factor)

      expect(j['app_group_barito_apps'][0]['app_name']).to eq(app1.name)
      expect(j['app_group_barito_apps'][0]['app_log_retention']).to eq(default_app_group_log_retention_days)

      expect(j['app_group_barito_apps'][1]['app_name']).to eq(app2.name)
      expect(j['app_group_barito_apps'][1]['app_log_retention']).to eq(default_app_group_log_retention_days)
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
              app_group_name: app_group.name,
              app_name: app1.name,
              app_log_bytes: 30000,
              calculation_price: 90003920,
            },
            {
              app_group_name: app_group.name,
              app_name: app2.name,
              app_log_bytes: 59182930,
              calculation_price: 273810589,
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
              app_group_name: app_group.name,
              app_name: app1.name,
              app_log_bytes: 30000,
              calculation_price: 90003920,
            },
            {
              app_group_name: app_group.name,
              app_name: app2.name,
              app_log_bytes: 59182930,
              calculation_price: 273810589,
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