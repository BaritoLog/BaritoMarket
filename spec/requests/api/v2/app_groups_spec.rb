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
        instances: cluster_template.instances,
        options: cluster_template.options,
      )
      post api_v2_create_app_group_path, params: { access_token: @access_token, name: app_group.name, cluster_template_id: cluster_template.id }, headers: headers
      json_response = JSON.parse(response.body)
      
      expect(json_response['data']['name']).to eq(app_group.name)
    end
  end
end
