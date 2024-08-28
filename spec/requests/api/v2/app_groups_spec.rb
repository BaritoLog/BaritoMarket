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
      cluster_name = "test-delete"
      app_group = create(:app_group, cluster_name: cluster_name)
      first_helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        cluster_name: cluster_name,
        status: HelmInfrastructure.statuses[:active],
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished],
      )
      second_helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        cluster_name: cluster_name,
        status: HelmInfrastructure.statuses[:active],
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished],
      )

      # Send a DELETE request to the delete action
      post api_v2_deactivated_by_cluster_name_path(cluster_name: cluster_name, app_group_name: app_group.name), params:{access_token: @access_token}, headers: headers

      # Expect a successful response
      expect(response.status).to eq(200)

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Expect the response to indicate success
      expect(json_response['success']).to eq(true)
      expect(json_response['message']).to eq('App Group deactivated successfully')

      # verify the appgroup are INACTIVE
      expect(app_group.reload.INACTIVE?).to eq(true)

      # Verify that the Helm Infrastructure has been deleted
      expect(HelmInfrastructure.find(first_helm_infrastructure.id).provisioning_status).to eq('DELETE_STARTED')
      expect(HelmInfrastructure.find(second_helm_infrastructure.id).provisioning_status).to eq('DELETE_STARTED')
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
      expect(json_response['errors']).to eq(['App Group not found'])
    end

    it 'should return 404 if AppGroup is not found' do
      # Send a DELETE request to the delete action with an invalid ID
      post api_v2_deactivated_by_cluster_name_path(cluster_name: 'nonexistent_cluster', app_group_name: 'nonexistent_group'), params:{access_token: @access_token}, headers: headers

      # Expect a 404 response
      expect(response.status).to eq(404)

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Expect the response to indicate failure and the reason
      expect(json_response['success']).to eq(false)
      expect(json_response['errors']).to eq(['App Group not found'])
    end

    it 'should return 404 if AppGroup already Inactive' do
      # Creae an Inactive AppGroup
      cluster_name = "test-delete"
      app_group = create(:app_group, cluster_name: cluster_name, status: :INACTIVE)

      # Send a DELETE request to the delete action
      post api_v2_deactivated_by_cluster_name_path(cluster_name: cluster_name, app_group_name: app_group.name),params:{access_token: @access_token}, headers: headers

      # Expect a 404 response
      expect(response.status).to eq(404)

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Expect the response to indicate failure and the reason
      expect(json_response['success']).to eq(false)
      expect(json_response['errors']).to eq(['App Group not found'])
    end
  end
end


RSpec.describe 'Create App Groups API', type: :request do
  let(:headers) do
    { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
  end
  let(:app_group_name) { 'Something Production' }
  let(:helm_cluster_template) { create(:helm_cluster_template) }

  before(:all) do
    @access_token = 'ABC123'
    @ext_app = create(:ext_app, access_token: @access_token)
  end

  after(:all) do
    @ext_app.destroy
  end

  it 'should create appgroup w/ HelmInfrastructure in default location' do
    infrastructure_location = create(:infrastructure_location, name: Figaro.env.default_infrastructure_location)

    create_params = {
      access_token: @access_token, name: app_group_name, cluster_template_id: helm_cluster_template.id,
    }

    post api_v2_create_app_group_path, params: create_params, headers: headers
    json_response = JSON.parse(response.body)

    app_group = AppGroup.find_by(name: app_group_name)
    expect(json_response['data']['name']).to eq(app_group_name)
    expect(json_response['data']['secret_key']).to eq(app_group.secret_key)
    expect(app_group.cluster_name).to eq(app_group.helm_infrastructures.first.cluster_name)
    expect(HelmInfrastructure.all.length).to eq(1)
    expect(HelmInfrastructure.first.infrastructure_location_id).to eq(infrastructure_location.id)
  end

  it 'should create appgroup w/ HelmInfrastructure in selected location' do
    infrastructure_location = create(:infrastructure_location, name: "new-location")

    create_params = {
      access_token: @access_token, name: app_group_name, cluster_template_id: helm_cluster_template.id, infrastructure_location_name: infrastructure_location.name,
    }

    post api_v2_create_app_group_path, params: create_params, headers: headers
    json_response = JSON.parse(response.body)

    app_group = AppGroup.find_by(name: app_group_name)
    expect(app_group.cluster_name).to eq(app_group.helm_infrastructures.first.cluster_name)
    expect(HelmInfrastructure.all.length).to eq(1)
    expect(HelmInfrastructure.first.infrastructure_location_id).to eq(infrastructure_location.id)
    expect(json_response['data']['name']).to eq(app_group_name)
    expect(json_response['data']['secret_key']).to eq(app_group.secret_key)
  end

  it 'should not create appgroup if location is not exists' do
    create_params = {
      access_token: @access_token, name: app_group_name, cluster_template_id: helm_cluster_template.id, infrastructure_location_name: "not-exists",
    }

    post api_v2_create_app_group_path, params: create_params, headers: headers
    expect(response.status).to eq(404)
    expect(AppGroup.find_by(name: app_group_name)).to be_nil
    expect(HelmInfrastructure.all.length).to eq(0)
  end

  it 'should not create appgroup if location is not active' do
    infrastructure_location = create(:infrastructure_location, :inactive)

    create_params = {
      access_token: @access_token, name: app_group_name, cluster_template_id: helm_cluster_template.id, infrastructure_location_name: infrastructure_location.name,
    }

    post api_v2_create_app_group_path, params: create_params, headers: headers
    expect(response.status).to eq(404)
    expect(AppGroup.find_by(name: app_group_name)).to be_nil
    expect(HelmInfrastructure.all.length).to eq(0)
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


  describe 'Check App Group API' do
    let(:app_group) { create(:app_group) }

    it 'when appgroup secret is not provided it should return 422' do
      error_msg = 'Invalid Params: app_group_secret is a required parameter'
      get api_v2_check_app_group_path, params: { access_token: @access_token, app_group_secret: '', app_name: "test-app-01" }, headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response['code']).to eq(422)
      expect(json_response['errors']).to eq([error_msg])
    end

    it 'should return app status information' do
      create(:helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active])

      get api_v2_check_app_group_path, params: { access_token: @access_token, app_group_secret: app_group.secret_key, app_name: "test-app-01" }, headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response.key?('provisioning_status')).to eq(true)
      expect(json_response['status']).to eq "ACTIVE"
    end

  end

  describe 'Profile app' do
    it 'should return list profile information of all Barito apps inside an appgroup when default log retention values of apps are used' do
      default_prod_replication_factor = 2

      app_group = create(:app_group, environment: 'production')

      app1 = create(:barito_app, app_group: app_group, topic_name: "topic1", name: "test-app-1", status: BaritoApp.statuses[:active])
      app2 = create(:barito_app, app_group: app_group, topic_name: "topic2", name: "test-app-2", status: BaritoApp.statuses[:active])

      get api_v2_profile_app_path,
        params: { access_token: @access_token},
        headers: headers

      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)

      expect(json_response.length).to eq(1)
      j = json_response[0]

      expect(j['app_group_name']).to eq(app_group.name)
      expect(j['app_group_cluster_name']).to eq(app_group.cluster_name)
      expect(j['app_group_replication_factor']).to eq(default_prod_replication_factor)

      expect(j['app_group_barito_apps'][0]['app_name']).to eq(app1.name)
      expect(j['app_group_barito_apps'][0]['app_log_retention']).to eq(app1.log_retention_days)

      expect(j['app_group_barito_apps'][1]['app_name']).to eq(app2.name)
      expect(j['app_group_barito_apps'][1]['app_log_retention']).to eq(app2.log_retention_days)
    end

    it 'should return list profile information of all Barito apps having appgroup\'s log retention days when default log retention values of apps are not used' do
      default_staging_replication_factor = 1
      default_app_group_log_retention_days = Figaro.env.DEFAULT_LOG_RETENTION_DAYS.to_i

      app_group = create(:app_group, environment: 'staging')

      app1 = create(:barito_app, app_group: app_group, topic_name: "topic1", name: "test-app-1", status: BaritoApp.statuses[:active], log_retention_days: nil)
      app2 = create(:barito_app, app_group: app_group, topic_name: "topic2", name: "test-app-2", status: BaritoApp.statuses[:active], log_retention_days: nil)

      get api_v2_profile_app_path,
        params: { access_token: @access_token},
        headers: headers

      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)

      expect(json_response.length).to eq(1)
      j = json_response[0]

      expect(j['app_group_name']).to eq(app_group.name)
      expect(j['app_group_cluster_name']).to eq(app_group.cluster_name)
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
