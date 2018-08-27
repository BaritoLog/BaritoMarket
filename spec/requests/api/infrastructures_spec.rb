require 'rails_helper'

RSpec.describe 'App API', type: :request do
  describe 'Profile by Cluster Name API' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return profile information of registered app when supplied cluster name' do
      app_group = create(:app_group)
      infrastructure = create(:infrastructure, app_group: app_group)

      get api_profile_by_cluster_name_path,
        params: { cluster_name: infrastructure.cluster_name },
        headers: headers
      json_response = JSON.parse(response.body)

      %w[name app_group_name capacity cluster_name consul_host status provisioning_status].each do |key|
        expect(json_response.key?(key)).to eq(true)
        expect(json_response[key]).to eq(infrastructure.send(key.to_sym))
      end
      expect(json_response.key?('updated_at')).to eq(true)
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
        infrastructure = create(:infrastructure, app_group: app_group)
        get api_authorize_path, params: { cluster_name: infrastructure.cluster_name, username: user_a[:username]  }, headers: headers

        expect(response.status).to eq 200
      end
    end

    context 'when invalid username or invalid cluster_name' do
      it 'should return 401' do
        app_group = create(:app_group)
        infrastructure = create(:infrastructure, app_group: app_group)
        get api_authorize_path, params: { cluster_name: "some-random-name", username: "some-user"  }, headers: headers

        expect(response.status).to eq 401
      end
    end
  end
end
