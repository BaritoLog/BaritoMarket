require 'rails_helper'

RSpec.describe 'Apps API', type: :request do
  let(:headers) do
    { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
  end

  let(:headers_with_tracing) do
    headers.merge('X-B3-SAMPLED' => "1",
                  'X-B3-SPANID' => '10509c69eec92c0e',
                  'X-B3-TRACEID' => '10509c69eec92c0e')
  end

  before(:all) do
    @access_token = 'ABC123'
    @ext_app = create(:ext_app, access_token: @access_token)
  end

  after(:all) do
    @ext_app.destroy
  end

  class Datadog::Statsd
    # we need to stub this
    attr_accessor :socket
  end

  let(:socket) { FakeUDPSocket.new }

  before do
    @statsd = Datadog::Statsd.new('localhost', 1234)
    @statsd.connection.instance_variable_set(:@socket, socket)
  end

  describe 'Profile API' do
    it 'should return profile information of registered app' do
      app_group = create(:app_group)
      create(:helm_infrastructure,
        app_group: app_group,
        status: HelmInfrastructure.statuses[:active],
        cluster_name: 'haza'
      )

      app = create(:barito_app, app_group: app_group, status: BaritoApp.statuses[:active])
      app_updated_at = app.updated_at.strftime(Figaro.env.timestamp_format)

      get api_v2_profile_path, params: { access_token: @access_token, app_secret: app.secret_key }, headers: headers
      json_response = JSON.parse(response.body)


      %w[name app_group_name max_tps cluster_name status].each do |key|
        expect(json_response.key?(key)).to eq(true)
        expect(json_response[key]).to eq(app.send(key.to_sym))
      end

      expect(json_response['producer_address']).to eq(app_group.helm_infrastructure.producer_address)
      expect(json_response.key?('updated_at')).to eq(true)
    end

    it 'should returns K8s producer address if available' do
      app_group = create(:app_group)
      create(:helm_infrastructure,
        app_group: app_group, 
        status: HelmInfrastructure.statuses[:active],
        cluster_name: 'haza'
      )
      app = create(:barito_app, app_group: app_group, status: BaritoApp.statuses[:active])

      get api_v2_profile_path, params: { access_token: @access_token, app_secret: app.secret_key }, headers: headers
      json_response = JSON.parse(response.body)
      
      expect(json_response['producer_address']).to match app.app_group.helm_infrastructure.producer_address
    end

    context 'when invalid token' do
      it 'should return 404' do
        secret_key = SecureRandom.uuid.gsub(/\-/, '')
        error_msg = "App not found or inactive"

        get api_v2_profile_path, params: { access_token: @access_token, app_secret: secret_key }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq(404)
        expect(json_response['errors']).to eq([error_msg])
      end
    end

    context 'when app_secret is not provided' do
      it 'should return 422' do
        error_msg = 'Invalid Params: app_secret is a required parameter'

        get api_v2_profile_path, params: { access_token: @access_token, app_secret: '' }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq(422)
        expect(json_response['errors']).to eq([error_msg])
      end
    end

    context 'when app_secret is provided and valid but app is inactive' do
      it 'should return 404' do
        error_msg = 'App not found or inactive'
        app_group = create(:app_group)
        create(:helm_infrastructure, app_group: app_group, status: Infrastructure.statuses[:active])
        app = create(:barito_app, app_group: app_group)

        get api_v2_profile_path, params: { access_token: @access_token, app_secret: app.secret_key }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq false
        expect(json_response['code']).to eq 404
        expect(json_response['errors']).to eq [error_msg]
      end
    end

    context 'when app_secret is provided and valid, app is active but helm infrastructure is inactive' do
      it 'should return 404' do
        error_msg = 'App not found or inactive'
        app_group = create(:app_group)
        create(:helm_infrastructure, app_group: app_group)
        app = create(:barito_app, app_group: app_group, status: BaritoApp.statuses[:active])

        get api_v2_profile_path, params: { access_token: @access_token, app_secret: app.secret_key }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq false
        expect(json_response['code']).to eq 404
        expect(json_response['errors']).to eq [error_msg]
      end
    end

    context 'when app_secret is provided and valid, app is active and infrastructure is active' do
      it 'should return appropriate app' do
        app_group = create(:app_group)
        create(:helm_infrastructure, 
          app_group: app_group, 
          status: HelmInfrastructure.statuses[:active]
        )
        app = create(:barito_app, app_group: app_group, name: "test-app-01", status: BaritoApp.statuses[:active])

        get api_v2_profile_path, params: { access_token: @access_token, app_secret: app.secret_key }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response.key?('app_group_name')).to eq(true)
        expect(json_response['name']).to eq "test-app-01"
      end
    end

    context 'when app_group_secret is not provided' do
      it 'should return 422' do
        error_msg = 'Invalid Params: app_group_secret is a required parameter'
        get api_v2_profile_by_app_group_path, params: { access_token: @access_token, app_group_secret: '', app_name: "test-app-01" }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq(422)
        expect(json_response['errors']).to eq([error_msg])
      end
    end

    context 'when app_group_secret is provided and valid but params[:app_name] is not provided' do
      it 'should return 422' do
        error_msg = 'Invalid Params: app_name is a required parameter'
        app_group = create(:app_group)

        get api_v2_profile_by_app_group_path, params: { access_token: @access_token, app_group_secret: app_group.secret_key }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq(422)
        expect(json_response['errors']).to eq([error_msg])
      end
    end

    context 'when app_group_secret is provided and have tracing headers' do
      it 'should return 422' do
        error_msg = 'Invalid Params: app_group_secret is a required parameter'
        get api_v2_profile_by_app_group_path, params: { access_token: @access_token, app_group_secret: '', app_name: "test-app-01" }, headers: headers_with_tracing
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq(422)
        expect(json_response['errors']).to eq([error_msg])
      end
    end

    context 'when app_group_secret is provided and valid and params[:app_name] is provided but app is inactive' do
      it 'should return 404' do
        error_msg = 'App is inactive'
        app_group = create(:app_group)
        create(:helm_infrastructure, 
          app_group: app_group, 
          status: HelmInfrastructure.statuses[:active]
        )
        app = create(:barito_app, app_group: app_group, name: "test-app-01", status: BaritoApp.statuses[:inactive])

        get api_v2_profile_by_app_group_path, params: { access_token: @access_token, app_group_secret: app_group.secret_key, app_name: "test-app-01" }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq false
        expect(json_response['code']).to eq 503
        expect(json_response['errors']).to eq [error_msg]
      end
    end

    context 'when app_group_secret is provided and valid and params[:app_name] is provided and app is active' do
      it 'should return appropriate app' do
        app_group = create(:app_group)
        create(:helm_infrastructure, 
          app_group: app_group, 
          status: HelmInfrastructure.statuses[:active]
        )
        app = create(:barito_app, app_group: app_group, name: "test-app-01", status: BaritoApp.statuses[:active])

        get api_v2_profile_by_app_group_path, params: { access_token: @access_token, app_group_secret: app_group.secret_key, app_name: "test-app-01" }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response.key?('app_group_name')).to eq(true)
        expect(json_response['name']).to eq "test-app-01"
      end
    end

    context 'when app_group_secret is provided and valid and params[:app_name] is provided and app is blank' do
      it 'should create new app with params[:app_name]' do
        app_group = create(:app_group)
        create(:helm_infrastructure, 
          app_group: app_group, 
          status: HelmInfrastructure.statuses[:active]
        )

        get api_v2_profile_by_app_group_path, params: { access_token: @access_token, app_group_secret: app_group.secret_key, app_name: "test-app-02" }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response.key?('app_group_name')).to eq(true)
        expect(json_response['name']).to eq "test-app-02"
      end
    end
  end

  describe 'Increase Log count API' do
    context 'when empty application_groups metrics' do
      it 'should return 404', :skip do
        post api_v2_increase_log_count_path, params: {access_token: @access_token, application_groups: []}, headers: headers

        expect(response.status).to eq 404
      end
    end

    context 'when valid token' do
      it 'should return 200' do
        app_group = create(:app_group)
        app = create(:barito_app, app_group: app_group, log_count: 0)

        post api_v2_increase_log_count_path, params: {access_token: @access_token, application_groups: [{token: app.secret_key, new_log_count: 10}]}, headers: headers
        json_response = JSON.parse(response.body)

        expect(response.status).to eq 200
        expect(json_response['data']).to be_empty
      end
    end

    context 'when invalid token' do
      it 'should return 404', :skip do
        secret_key = SecureRandom.uuid.gsub(/\-/, '')
        error_msg = "#{secret_key} : is not a valid App Secret"

        post api_v2_increase_log_count_path, params: {access_token: @access_token, application_groups: [{token: secret_key, new_log_count: 10}]}, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq 404
        expect(json_response['errors']).to eq([error_msg])
      end
    end
  end

  describe "DogStatsD API" do
    it "should send a message with a 'g' type" do
      @statsd.gauge('begrutten-suffusion', 536)
      expect(socket.recv).to include('begrutten-suffusion:536|g')
    end
  end
end
