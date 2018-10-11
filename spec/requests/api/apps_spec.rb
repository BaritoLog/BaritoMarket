require 'rails_helper'

RSpec.describe 'Apps API', type: :request do
  let(:headers) do
    { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
  end

  describe 'Profile API' do
    it 'should return profile information of registered app' do
      app_group = create(:app_group)
      create(:infrastructure,
        app_group: app_group,
        status: Infrastructure.statuses[:active],
        capacity: "small")
      app = create(:barito_app, app_group: app_group, status: BaritoApp.statuses[:active])
      app_updated_at = app.updated_at.strftime(Figaro.env.timestamp_format)
      get api_profile_path, params: { token: app.secret_key }, headers: headers
      json_response = JSON.parse(response.body)
      %w[name app_group_name max_tps cluster_name consul_host status].each do |key|
        expect(json_response.key?(key)).to eq(true)
        expect(json_response[key]).to eq(app.send(key.to_sym))
      end
      expect(json_response.key?('updated_at')).to eq(true)
      expect(json_response['updated_at']).to eq(app_updated_at)
      expect(json_response['meta']['kafka']['replication_factor']).to eq(1)
      expect(json_response['meta']['kafka']['partition']).to eq(1)
    end

    context 'when invalid token' do
      it 'should return 404' do
        secret_key = SecureRandom.uuid.gsub(/\-/, '')
        error_msg = "App not found or inactive"
        get api_profile_path, params: { token: secret_key }, headers: headers
        json_response = JSON.parse(response.body)
        expect(json_response['code']).to eq(404)
        expect(json_response['errors']).to eq([error_msg])
      end
    end

    context 'when token is not provided' do
      it 'should return 422' do
        error_msg = 'Invalid Params: token is a required parameter'
        get api_profile_path, params: { token: '' }, headers: headers
        json_response = JSON.parse(response.body)
        expect(json_response['code']).to eq(422)
        expect(json_response['errors']).to eq([error_msg])
      end
    end

    context 'when token is provided and valid but app is inactive' do
      it 'should return 404' do
        error_msg = 'App not found or inactive'
        app_group = create(:app_group)
        create(:infrastructure, app_group: app_group, status: Infrastructure.statuses[:active])
        app = create(:barito_app, app_group: app_group)
        get api_profile_path, params: { token: app.secret_key }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq false
        expect(json_response['code']).to eq 404
        expect(json_response['errors']).to eq [error_msg]
      end
    end

    context 'when token is provided and valid, app is active but infrastructure is inactive' do
      it 'should return 404' do
        error_msg = 'App not found or inactive'
        app_group = create(:app_group)
        create(:infrastructure, app_group: app_group)
        app = create(:barito_app, app_group: app_group, status: BaritoApp.statuses[:active])
        get api_profile_path, params: { token: app.secret_key }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq false
        expect(json_response['code']).to eq 404
        expect(json_response['errors']).to eq [error_msg]
      end
    end
  end

  describe 'Increase Log count API' do
    context 'when empty application_groups metrics' do
      it 'should return 404' do
        post api_increase_log_count_path, params: {application_groups: []}, headers: headers
        expect(response.status).to eq 404
      end
    end

    context 'when valid token' do
      it 'should return 200' do
        app_group = create(:app_group)
        app = create(:barito_app, app_group: app_group)

        expect(app.log_count).to be_zero
        post api_increase_log_count_path, params: {application_groups: [{token: app.secret_key, new_log_count: 10}]}, headers: headers
        json_response = JSON.parse(response.body)

        expect(response.status).to eq 200
        expect(json_response['data'][0]['log_count']).to eq(10)
      end
    end

    context 'when invalid token' do
      it 'should return 404' do
        secret_key = SecureRandom.uuid.gsub(/\-/, '')
        error_msg = "#{secret_key} : is not a valid App Secret"
        post api_increase_log_count_path, params: {application_groups: [{token: secret_key, new_log_count: 10}]}, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq 404
        expect(json_response['errors']).to eq([error_msg])
      end
    end
  end

  describe 'Dogapi API' do
    let(:api_key) { 'API_KEY' }
    let(:dog) { Dogapi::Client.new(api_key) }
    let(:api_url) { 'api.datadoghq.com/api/v1' }

    describe '#emit_point' do
      it 'post metric to the datadog api' do
        METRIC = 'test.metric'.freeze
        POINT = 10
         url = api_url + '/series'
        stub_request(:post, /#{url}/).to_return(body: '{}').then.to_raise(StandardError)
        expect(dog.send(:emit_point, METRIC, POINT)).to eq ['200', {}]
      end
    end
  end
end
