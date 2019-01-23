require 'rails_helper'

RSpec.describe 'App API', type: :request do
  before(:all) do
    @access_token = 'ABC123'
    @ext_app = create(:ext_app, access_token: @access_token)
  end

  after(:all) do
    @ext_app.destroy
  end
  
  describe 'Profile by Cluster Name API' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return profile information of registered app when supplied cluster name' do
      app_group = create(:app_group)
      infrastructure = create(:infrastructure, app_group: app_group, status: Infrastructure.statuses[:active])

      get api_v2_profile_by_cluster_name_path,
        params: { access_token: @access_token, cluster_name: infrastructure.cluster_name },
        headers: headers
      json_response = JSON.parse(response.body)

      %w[name app_group_name capacity cluster_name consul_host status provisioning_status].each do |key|
        expect(json_response.key?(key)).to eq(true)
        expect(json_response[key]).to eq(infrastructure.send(key.to_sym))
      end
      expect(json_response.key?('updated_at')).to eq(true)
    end

    context 'when infrastructure inactive' do
      it 'should return 404' do
        error_msg = 'Infrastructure not found'
        app_group = create(:app_group)
        infrastructure = create(:infrastructure, app_group: app_group)

        get api_v2_profile_by_cluster_name_path,
          params: { access_token: @access_token, cluster_name: infrastructure.cluster_name },
          headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq false
        expect(json_response['code']).to eq 404
        expect(json_response['errors']).to eq [error_msg]
      end
    end
  end

  describe 'Profile for Curator' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return list of all active App with its retention policy for curator' do
      app_group = create(:app_group)
      infrastructure = create(:infrastructure, app_group: app_group)
      infrastructure_component = create(:infrastructure_component, infrastructure: infrastructure, category: 'elasticsearch', status: InfrastructureComponent.statuses[:finished])
      create(:barito_app, app_group: app_group, status: BaritoApp.statuses[:active])

      get api_v2_profile_curator_path,
        params: { access_token: @access_token, client_key: 'abcd1234' },
        headers: headers
      expect(response.body).to eq [
        {
          hostname: infrastructure_component.hostname,
          ipaddress: infrastructure_component.ipaddress,
          log_retention_days: app_group.log_retention_days
        }
      ].to_json
    end
  end

  describe 'Authorize API' do
    let(:user_a) { create(:user) }

    context 'when valid username and valid cluster_name' do
      it 'should return 200' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        create(:group, name: 'barito-superadmin')
        app_group = create(:app_group)
        infrastructure = create(:infrastructure, app_group: app_group, status: Infrastructure.statuses[:active])
        get api_v2_authorize_path, params: { access_token: @access_token, cluster_name: infrastructure.cluster_name, username: user_a[:username]  }, headers: headers

        expect(response.status).to eq 200
      end
    end

    context 'when invalid username or invalid cluster_name' do
      it 'should return 403' do
        app_group = create(:app_group)
        create(:infrastructure, app_group: app_group)
        get api_v2_authorize_path, params: { access_token: @access_token, cluster_name: "some-random-name", username: "some-user"  }, headers: headers

        expect(response.status).to eq 403
      end
    end

    context 'when valid username and cluster name but with inactive infrastructure' do
      it 'should return 403' do
        app_group = create(:app_group)
        infrastructure = create(:infrastructure, app_group: app_group)
        get api_v2_authorize_path, params: { access_token: @access_token, cluster_name: infrastructure.cluster_name, username: user_a.username  }, headers: headers

        expect(response.status).to eq 403
      end
    end
  end
end
