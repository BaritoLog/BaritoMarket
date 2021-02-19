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

  before(:each) do
    pf_host = Figaro.env.pathfinder_host
    pf_token = Figaro.env.pathfinder_token
    pf_cluster = Figaro.env.pathfinder_cluster
    @pf_provisioner = PathfinderProvisioner.new(pf_host, pf_token, pf_cluster)
    @manifest = {
      "name" => "haza-consul",
      "cluster_name" => "barito",
      "deployment_cluster_name"=>"haza",
      "type" => "consul",
      "desired_num_replicas" => 1,
      "min_available_replicas" => 0,
      "definition" => {
        "container_type" => "stateless",
        "strategy" => "RollingUpdate",
        "allow_failure" => "false",
        "source" => {
          "mode" => "pull",              # can be local or pull. default is pull.
          "alias" => "lxd-ubuntu-minimal-consul-1.1.0-8",
          "remote" => {
            "name" => "barito-registry"
          },
          "fingerprint" => "",
          "source_type" => "image"
        },
        "resource" => {
          "cpu_limit" => "0-2",
          "mem_limit" => "500MB"
        },
        "bootstrappers" => [{
          "bootstrap_type" => "chef-solo",
          "bootstrap_attributes" => {
            "consul" => {
              "hosts" => []
            },
            "run_list" => []
          },
          "bootstrap_cookbooks_url" => "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
        }],
        "healthcheck" => {
          "type" => "tcp",
          "port" => 9500,
          "endpoint" => "",
          "payload" => "",
          "timeout" => ""
        }
      }
    }
    @resp = {
        'success'=> true,
        'data' =>{
          "containers"=>[{
            "id"=>1817,
            "hostname"=>"haza-consul-01",
            "ipaddress"=>"10.0.0.1",
            "source"=>{
              "id"=>23,
              "source_type"=>"image",
              "mode"=>"pull",
              "remote"=>{
                "id"=>1,
                "name"=>"barito-registry",
                "server"=>"https://localhost:8443",
                "protocol"=>"lxd",
                "auth_type"=>"tls"
              },
              "fingerprint"=>"",
              "alias"=>"lxd-ubuntu-minimal-consul-1.1.0-8"
            },
            "bootstrappers"=>[{
              "bootstrap_type"=>"chef-solo",
              "bootstrap_attributes"=>{
                "consul"=>{
                  "hosts"=>["10.0.0.1"]
                },
                "run_list"=>[]
              },
              "bootstrap_cookbooks_url"=>
                "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"}],
            "node_hostname"=>"i-barito-worker-node-02",
            "status"=>"BOOTSTRAPPED",
            "last_status_update_at"=>"2020-03-19T07:27:54.885Z"}
          ]
        }
      }
  end

  describe 'Profile API' do
    it 'should return profile information of registered app' do
      app_group = create(:app_group)
      cluster_template = create(:cluster_template)
      create(:infrastructure,
        app_group: app_group,
        status: Infrastructure.statuses[:active],
        capacity: 'small',
        cluster_template: cluster_template,
        cluster_name: 'haza',
        manifests: [@manifest],
        options: cluster_template.options,
      )

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-consul', 'barito').and_return(@resp))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      app = create(:barito_app, app_group: app_group, status: BaritoApp.statuses[:active])
      app_updated_at = app.updated_at.strftime(Figaro.env.timestamp_format)

      get api_v2_profile_path, params: { access_token: @access_token, app_secret: app.secret_key }, headers: headers
      json_response = JSON.parse(response.body)

      %w[name app_group_name max_tps cluster_name status].each do |key|
        expect(json_response.key?(key)).to eq(true)
        expect(json_response[key]).to eq(app.send(key.to_sym))
      end

      expect(json_response['consul_host']).to eq('10.0.0.1:8500')
      expect(json_response.key?('updated_at')).to eq(true)
      expect(json_response['updated_at']).to eq(app_updated_at)
      expect(json_response['meta']['kafka']['replication_factor']).to eq(1)
      expect(json_response['meta']['kafka']['partition']).to eq(1)
    end

    it 'should returns multiple Consul instances from related infrastructure_component' do
      app_group = create(:app_group)
      cluster_template = create(:cluster_template)
      create(:infrastructure,
        app_group: app_group,
        status: Infrastructure.statuses[:active],
        capacity: "small",
        cluster_template: cluster_template,
        cluster_name: 'haza',
        manifests: [@manifest],
        options: cluster_template.options,
        consul_host: "localhost:8500",
      ).tap do |infrastructure|
        create(:infrastructure_component,
          infrastructure: infrastructure,
          ipaddress: '192.168.0.1',
          component_type: 'consul',
        )
        create(:infrastructure_component,
          infrastructure: infrastructure,
          ipaddress: '192.168.0.2',
          component_type: 'consul',
        )
      end
      app = create(:barito_app, app_group: app_group, status: BaritoApp.statuses[:active])
      app_updated_at = app.updated_at.strftime(Figaro.env.timestamp_format)

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-consul', 'barito').and_return([]))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      get api_v2_profile_path, params: { access_token: @access_token, app_secret: app.secret_key }, headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response['consul_hosts']).to match_array ['192.168.0.1:8500', '192.168.0.2:8500']
      expect(json_response['consul_host']).to match 'localhost:8500'
    end

    it 'should returns multiple Consul instances from related pf deployment' do
      app_group = create(:app_group)
      cluster_template = create(:cluster_template)
      create(:infrastructure,
        app_group: app_group,
        status: Infrastructure.statuses[:active],
        capacity: 'small',
        cluster_template: cluster_template,
        cluster_name: 'haza',
        manifests: [@manifest],
        options: cluster_template.options,
        consul_host: "localhost:8500",
      )
      app = create(:barito_app, app_group: app_group, status: BaritoApp.statuses[:active])

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-consul', 'barito').and_return(@resp))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      get api_v2_profile_path, params: { access_token: @access_token, app_secret: app.secret_key }, headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response['consul_hosts']).to match_array ['10.0.0.1:8500']
      expect(json_response['consul_host']).to match '10.0.0.1:8500'
    end

    it 'should returns K8s producer address if available' do
      app_group = create(:app_group)
      cluster_template = create(:cluster_template)
      create(:infrastructure,
        app_group: app_group,
        status: Infrastructure.statuses[:active],
        capacity: 'small',
        cluster_template: cluster_template,
        cluster_name: 'haza',
        manifests: [@manifest],
        options: cluster_template.options,
        consul_host: "localhost:8500",
      )
      app = create(:barito_app, app_group: app_group, status: BaritoApp.statuses[:active])
      create(:helm_infrastructure, app_group: app_group, is_active: true)

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-consul', 'barito').and_return(@resp))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      get api_v2_profile_path, params: { access_token: @access_token, app_secret: app.secret_key }, headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response['producer_address']).to match "haza-producer.barito-worker.svc:8080"
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
        create(:infrastructure, app_group: app_group, status: Infrastructure.statuses[:active])
        app = create(:barito_app, app_group: app_group)

        get api_v2_profile_path, params: { access_token: @access_token, app_secret: app.secret_key }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq false
        expect(json_response['code']).to eq 404
        expect(json_response['errors']).to eq [error_msg]
      end
    end

    context 'when app_secret is provided and valid, app is active but infrastructure is inactive' do
      it 'should return 404' do
        error_msg = 'App not found or inactive'
        app_group = create(:app_group)
        create(:infrastructure, app_group: app_group)
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
        create(:infrastructure, app_group: app_group, status: Infrastructure.statuses[:active])
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
        create(:infrastructure, app_group: app_group, status: Infrastructure.statuses[:active])
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
        create(:infrastructure, app_group: app_group, status: Infrastructure.statuses[:active])
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
        create(:infrastructure, app_group: app_group, status: Infrastructure.statuses[:active])

        get api_v2_profile_by_app_group_path, params: { access_token: @access_token, app_group_secret: app_group.secret_key, app_name: "test-app-02" }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response.key?('app_group_name')).to eq(true)
        expect(json_response['name']).to eq "test-app-02"
      end
    end
  end

  describe 'Increase Log count API' do
    context 'when empty application_groups metrics' do
      it 'should return 404' do
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
        expect(json_response['data'][0]['log_count']).to eq(10)
      end
    end

    context 'when invalid token' do
      it 'should return 404' do
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
