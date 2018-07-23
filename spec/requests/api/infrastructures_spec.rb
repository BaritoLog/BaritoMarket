require 'rails_helper'

RSpec.describe 'App API', type: :request do
  before(:each) { login_as(create(:user)) }

  describe 'Profile by Cluster Name API' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return profile information of registered app when supplied cluster name' do
      app_group = create(:app_group)
      infrastructure = create(:infrastructure, app_group: app_group)
      # app_updated_at = app.updated_at.strftime(Figaro.env.timestamp_format)
      get api_profile_by_cluster_name_path,
        params: { cluster_name: infrastructure.cluster_name },
        headers: headers
      json_response = JSON.parse(response.body)
      %w[name app_group_name capacity cluster_name consul_host status provisioning_status].each do |key|
        expect(json_response.key?(key)).to eq(true)
        expect(json_response[key]).to eq(infrastructure.send(key.to_sym))
      end
      expect(json_response.key?('updated_at')).to eq(true)
      # expect(json_response['updated_at']).to eq(app_updated_at)
    end
  end
end
