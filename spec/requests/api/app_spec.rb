require 'rails_helper'

RSpec.describe 'App API', type: :request do
  describe 'Profile API' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end
    it 'should return profile information of registered app' do
      app = create(:barito_app)
      get api_profile_path, params: { token: app.secret_key }, headers: headers
      json_response = JSON.parse(response.body)
      %w[name app_group tps_config cluster_name app_status].each do |key|
        expect(json_response.key?(key)).to eq(true)
        expect(json_response[key]).to eq(app.send(key.to_sym))
      end
      expect(json_response.key?('updated_at')).to eq(true)
      expect(json_response['updated_at']).to eq(app.updated_at.strftime(Figaro.env.timestamp_format))
    end
    it 'should return 401 for invalid token' do
      secret_key = SecureRandom.uuid.gsub(/\-/, '')
      get api_profile_path, params: { token: secret_key }, headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response['code']).to eq(401)
      expect(json_response['errors']).to eq(["Unauthorized: #{secret_key} is not a valid App Token"])
    end
    it 'should return 422, when token is not provided' do
      get api_profile_path, params: { token: '' }, headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response['code']).to eq(422)
      expect(json_response['errors']).to eq(['Invalid Params: token is a required parameter'])
    end
  end
end
