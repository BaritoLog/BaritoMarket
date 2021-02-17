require 'rails_helper'

RSpec.describe 'App API', type: :request do
  before(:all) do
    @access_token = 'ABC123'
    @ext_app = create(:ext_app, access_token: @access_token)
  end

  after(:all) do
    @ext_app.destroy
  end

  before(:each) do
    @consul_manifest = {
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
    @elasticsearch_manifest = {
      "name" => "haza-elasticsearch",
      "cluster_name" => "barito",
      "deployment_cluster_name"=>"haza",
      "type" => "elasticsearch",
      "desired_num_replicas" => 1,
      "min_available_replicas" => 0,
      "definition" => {
        "container_type" => "stateless",
        "strategy" => "RollingUpdate",
        "allow_failure" => "false",
        "source" => {
          "mode" => "pull",              # can be local or pull. default is pull.
          "alias" => "lxd-ubuntu-minimal-elasticsearch-1.1.0-8",
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
            "elasticsearch" => {
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
    @elasticsearch_resp = {
        'success'=> true,
        'data' =>{
          "containers"=>[
            {
              "id"=>1818,
              "hostname"=>"haza-elasticsearch-01",
              "ipaddress"=>"10.0.0.2",
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
                "alias"=>"lxd-ubuntu-minimal-elasticsearch-1.1.0-8"
              },
              "bootstrappers"=>[{
                "bootstrap_type"=>"chef-solo",
                "bootstrap_attributes"=>{
                  "elasticsearch"=>{
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
      @consul_resp = {
        'success'=> true,
        'data' =>{
          "containers"=>[
            {
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
              "last_status_update_at"=>"2020-03-19T07:27:54.885Z"
            }
          ]
        }
      }
  end

  describe 'List Profile' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return list profile information of registered appgroups' do
      Infrastructure.delete_all

      app_group = create(:app_group)
      infrastructure = create(
        :infrastructure,
        app_group: app_group,
        status: Infrastructure.statuses[:active],
        provisioning_status: Infrastructure.provisioning_statuses[:deployment_finished]
      )
      consul = create(
        :infrastructure_component,
        infrastructure: infrastructure,
        status: Infrastructure.statuses[:active],
        component_type: "consul"
      )

      get api_v2_profile_index_path,
        params: { access_token: @access_token},
        headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response.length).to eq(1)
      j = json_response[0]
      %w[name app_group_name cluster_name status provisioning_status].
        each do |key|
          expect(j.key?(key)).to eq(true)
          expect(j[key]).to eq(app_group.infrastructure.send(key.to_sym))
        end
      expect(j["consul_hosts"].length).to eq(1)

    end

    it 'should return paginated response' do
      Infrastructure.delete_all
      app_groups = []
      12.times do |i|
        app_group = create(:app_group)
        infrastructure = create(
          :infrastructure,
          app_group: app_group,
          status: Infrastructure.statuses[:active],
          provisioning_status: Infrastructure.provisioning_statuses[:deployment_finished]
        )
        consul = create(
          :infrastructure_component,
          infrastructure: infrastructure,
          status: Infrastructure.statuses[:active],
          component_type: "consul"
        )
        app_groups << app_group
      end

      get api_v2_profile_index_path,
        params: { access_token: @access_token},
        headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(10)

      get api_v2_profile_index_path,
        params: { access_token: @access_token, page: 2},
        headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)

      get api_v2_profile_index_path,
        params: { access_token: @access_token, limit: 20},
        headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(12)
    end
  end

  describe 'Profile by Cluster Name API' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return profile information of registered app when supplied cluster name' do
      app_group = create(:app_group)
      infrastructure = create(
        :infrastructure,
        app_group: app_group,
        status: Infrastructure.statuses[:active]
      )

      get api_v2_profile_by_cluster_name_path,
        params: { access_token: @access_token, cluster_name: infrastructure.cluster_name },
        headers: headers
      json_response = JSON.parse(response.body)

      %w[name app_group_name app_group_secret capacity cluster_name consul_host status provisioning_status].
        each do |key|
          expect(json_response.key?(key)).to eq(true)
          expect(json_response[key]).to eq(infrastructure.send(key.to_sym))
        end
      expect(json_response.key?('updated_at')).to eq(true)
    end

    it 'should returns multiple Consul instances from related infrastructure_component' do
      app_group = create(:app_group)
      cluster_template = create(:cluster_template)
      infrastructure = create(:infrastructure,
        app_group: app_group,
        status: Infrastructure.statuses[:active],
        capacity: "small",
        cluster_template: cluster_template,
        cluster_name: 'haza',
        manifests: [@consul_manifest],
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

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-consul', 'barito').and_return([]))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      get api_v2_profile_by_cluster_name_path,
        params: { access_token: @access_token, cluster_name: infrastructure.cluster_name },
        headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response['consul_hosts']).to match_array ['192.168.0.1:8500', '192.168.0.2:8500']
      expect(json_response['consul_host']).to match 'localhost:8500'
    end

    it 'should returns multiple Consul instances from related pf deployment' do
      app_group = create(:app_group)
      cluster_template = create(:cluster_template)
      infrastructure = create(:infrastructure,
        app_group: app_group,
        status: Infrastructure.statuses[:active],
        capacity: 'small',
        cluster_template: cluster_template,
        cluster_name: 'haza',
        manifests: [@consul_manifest],
        options: cluster_template.options,
        consul_host: "localhost:8500",
      )

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-consul', 'barito').and_return(@consul_resp))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      get api_v2_profile_by_cluster_name_path,
        params: { access_token: @access_token, cluster_name: infrastructure.cluster_name },
        headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response['consul_hosts']).to match_array ['10.0.0.1:8500']
      expect(json_response['consul_host']).to match '10.0.0.1:8500'
    end

    it 'should return K8s Kibana if activated' do
      app_group = create(:app_group)
      cluster_template = create(:cluster_template)
      infrastructure = create(:infrastructure,
        app_group: app_group,
        status: Infrastructure.statuses[:active],
        capacity: 'small',
        cluster_template: cluster_template,
        cluster_name: 'haza',
        manifests: [@consul_manifest],
        options: cluster_template.options,
        consul_host: "localhost:8500",
      )
      create(:helm_infrastructure, app_group: app_group, use_k8s_kibana: true)

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-consul', 'barito').and_return(@consul_resp))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      get api_v2_profile_by_cluster_name_path,
        params: { access_token: @access_token, cluster_name: infrastructure.cluster_name },
        headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response['kibana_address']).to eq("#{infrastructure.cluster_name}-barito-worker-kb-http.barito-worker.svc:5601")
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
      app1 = create(:barito_app, topic_name: 'topic1', app_group: app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      infrastructure = create(:infrastructure, app_group: app_group, provisioning_status: Infrastructure.provisioning_statuses[:finished])
      infrastructure_component = create(
        :infrastructure_component,
        infrastructure: infrastructure,
        component_type: 'elasticsearch',
        status: InfrastructureComponent.statuses[:finished],
      )

      get api_v2_profile_curator_path,
        params: { access_token: @access_token, client_key: 'abcd1234' },
        headers: headers

      expect(response.body).to eq [
        {
          ipaddress: infrastructure_component.ipaddress,
          log_retention_days: app_group.log_retention_days,
          log_retention_days_per_topic: {
            app2.topic_name => app2.log_retention_days
          },
        }
      ].to_json
    end

    it 'should return es ipaddress from pathfinder' do
      app_group = create(:app_group)
      app1 = create(:barito_app, topic_name: 'topic1', app_group: app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      infrastructure = create(
        :infrastructure,
        app_group: app_group,
        provisioning_status: Infrastructure.provisioning_statuses[:finished],
        manifests: [@elasticsearch_manifest]
      )
      infrastructure_component = create(
        :infrastructure_component,
        infrastructure: infrastructure,
        component_type: 'elasticsearch',
        status: InfrastructureComponent.statuses[:finished]
      )

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-elasticsearch', 'barito').and_return(@elasticsearch_resp))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      get api_v2_profile_curator_path,
        params: { access_token: @access_token, client_key: 'abcd1234' },
        headers: headers

      expect(response.body).to eq [
        {
          ipaddress: '10.0.0.2',
          log_retention_days: app_group.log_retention_days,
          log_retention_days_per_topic: {
            app2.topic_name => app2.log_retention_days
          },
        }
      ].to_json
    end

    it 'should return K8s Elasticsearch address' do
      app_group = create(:app_group)
      app1 = create(:barito_app, topic_name: 'topic1', app_group: app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      infrastructure = create(
        :infrastructure,
        app_group: app_group,
        provisioning_status: Infrastructure.provisioning_statuses[:finished],
        manifests: [@elasticsearch_manifest]
      )
      create(:helm_infrastructure, app_group: app_group)

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-elasticsearch', 'barito').and_return(@elasticsearch_resp))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      get api_v2_profile_curator_path,
        params: { access_token: @access_token, client_key: 'abcd1234' },
        headers: headers

      expect(JSON.parse(response.body)).to include({
        "ipaddress" => "#{infrastructure.cluster_name}-barito-worker-es-http.barito-worker.svc",
        "log_retention_days" => app_group.log_retention_days,
        "log_retention_days_per_topic" => {
          app2.topic_name => app2.log_retention_days
        },
      })
    end

    it 'should return es ipaddress from infrastructure_component' do
      app_group = create(:app_group)
      app1 = create(:barito_app, topic_name: 'topic1', app_group: app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      infrastructure = create(
        :infrastructure,
        app_group: app_group,
        provisioning_status: Infrastructure.provisioning_statuses[:finished],
        manifests: [@elasticsearch_manifest]
      )
      infrastructure_component = create(
        :infrastructure_component,
        infrastructure: infrastructure,
        component_type: 'elasticsearch',
        status: InfrastructureComponent.statuses[:finished]
      )

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-elasticsearch', 'barito').and_return([]))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      get api_v2_profile_curator_path,
        params: { access_token: @access_token, client_key: 'abcd1234' },
        headers: headers

      expect(response.body).to eq [
        {
          ipaddress: infrastructure_component.ipaddress,
          log_retention_days: app_group.log_retention_days,
          log_retention_days_per_topic: {
            app2.topic_name => app2.log_retention_days
          },
        }
      ].to_json
    end

    it 'should works for DEPLOYMENT_FINISHED infrastructures' do
      app_group = create(:app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      infrastructure = create(:infrastructure, app_group: app_group, provisioning_status: Infrastructure.provisioning_statuses[:deployment_finished])
      infrastructure_component = create(
        :infrastructure_component,
        infrastructure: infrastructure,
        component_type: 'elasticsearch',
        status: InfrastructureComponent.statuses[:finished],
      )

      get api_v2_profile_curator_path,
        params: { access_token: @access_token, client_key: 'abcd1234' },
        headers: headers

      expect(response.body).to eq [
        {
          ipaddress: infrastructure_component.ipaddress,
          log_retention_days: app_group.log_retention_days,
          log_retention_days_per_topic: {
            app2.topic_name => app2.log_retention_days
          },
        }
      ].to_json
    end


  end

  describe 'Profile for Prometheus Exporters' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return list of all infrastructure components with environment label' do
      app_group_a = create(:app_group, environment: AppGroup.environments[:staging])
      infrastructure_a = create(:infrastructure, app_group: app_group_a)
      infrastructure_component_a = create(
        :infrastructure_component, infrastructure: infrastructure_a,
                                   status: InfrastructureComponent.statuses[:finished]
      )

      get api_v2_profile_prometheus_exporter_path,
        params: { access_token: @access_token }, headers: headers

      expect(response.body).to eq [
        {
          cluster_name: infrastructure_a.cluster_name,
          component_type: infrastructure_component_a.component_type,
          environment: app_group_a.environment,
          ipaddress: infrastructure_component_a.ipaddress,
        }
      ].to_json
    end
  end

  describe 'Authorize API' do
    let(:user_a) { create(:user) }

    context 'when valid username and valid cluster_name' do
      it 'should return 200' do
        set_check_user_groups('groups': ['barito-superadmin'])
        login_as user_a
        create(:group, name: 'barito-superadmin')
        app_group = create(:app_group)
        infrastructure = create(
          :infrastructure, app_group: app_group, status: Infrastructure.statuses[:active]
        )

        get api_v2_authorize_path, params: {
          access_token: @access_token,
          cluster_name: infrastructure.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 200
      end
    end

    context 'when invalid username or invalid cluster_name' do
      it 'should return 403' do
        app_group = create(:app_group)
        create(:infrastructure, app_group: app_group)

        get api_v2_authorize_path, params: {
          access_token: @access_token,
          cluster_name: 'some-random-name',
          username: 'some-user',
        }, headers: headers

        expect(response.status).to eq 403
      end
    end

    context 'when valid username and cluster name but with inactive infrastructure' do
      it 'should return 403' do
        app_group = create(:app_group)
        infrastructure = create(:infrastructure, app_group: app_group)

        get api_v2_authorize_path, params: {
          access_token: @access_token,
          cluster_name: infrastructure.cluster_name,
          username: user_a.username,
        }, headers: headers

        expect(response.status).to eq 403
      end
    end
  end
end
