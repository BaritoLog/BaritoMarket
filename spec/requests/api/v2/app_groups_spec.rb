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
      cluster_template = create(:cluster_template)
      create(:infrastructure,
        app_group: app_group,
        status: Infrastructure.statuses[:active],
        capacity: "small",
        cluster_template: cluster_template,
        manifests: cluster_template.manifests,
        options: cluster_template.options,
      )
      post api_v2_create_app_group_path, params: { access_token: @access_token, name: app_group.name, cluster_template_id: cluster_template.id }, headers: headers
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
      create(:infrastructure, app_group: app_group, status: Infrastructure.statuses[:active])
      app = create(:barito_app, app_group: app_group, name: "test-app-01", status: BaritoApp.statuses[:active])
      
      get api_v2_check_app_group_path, params: { access_token: @access_token, app_group_secret: app_group.secret_key, app_name: "test-app-01" }, headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response.key?('provisioning_status')).to eq(true)
      expect(json_response['status']).to eq "ACTIVE"
    end

    it 'should return cluster template' do
      cluster_template = create(:cluster_template)
      get api_v2_cluster_templates_path, params: { access_token: @access_token}, headers: headers

      json_response = JSON.parse(response.body)
      expected_result = [{"id"=>cluster_template.id, "name"=>"#{cluster_template.name}"}]
      expect(json_response).to eq expected_result
    end
  end
end
