require 'rails_helper'

RSpec.describe 'App API', type: :request do
  describe 'Profile for Curator' do
    before(:all) do
      @access_token = 'ABC123'
      @ext_app = create(:ext_app, access_token: @access_token)
    end

    after(:all) do
      @ext_app.destroy
    end

    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    before(:each) do
      @manifest = {
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
              "hostname"=>"haza-elasticsearch-01",
              "ipaddress"=>"10.0.0.5",
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

      get api_profile_curator_path,
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

    it 'should get es ipaddress value from pathfinder' do
      app_group = create(:app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      infrastructure = create(
        :infrastructure,
        app_group: app_group,
        provisioning_status: Infrastructure.provisioning_statuses[:deployment_finished],
        manifests: [@manifest]
      )
      infrastructure_component = create(
        :infrastructure_component,
        infrastructure: infrastructure,
        component_type: 'elasticsearch',
        status: InfrastructureComponent.statuses[:finished],
      )

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-elasticsearch', 'barito').and_return(@resp))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      get api_profile_curator_path,
          params: { access_token: @access_token, client_key: 'abcd1234' },
          headers: headers

      expect(response.body).to eq [
        {
          ipaddress: '10.0.0.5',
          log_retention_days: app_group.log_retention_days,
          log_retention_days_per_topic: {
            app2.topic_name => app2.log_retention_days
          },
        }
      ].to_json
    end

    it 'should get es ipaddress value from infrastructure_component' do
      app_group = create(:app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      infrastructure = create(
        :infrastructure,
        app_group: app_group,
        provisioning_status: Infrastructure.provisioning_statuses[:deployment_finished],
        manifests: [@manifest]
      )
      infrastructure_component = create(
        :infrastructure_component,
        infrastructure: infrastructure,
        component_type: 'elasticsearch',
        status: InfrastructureComponent.statuses[:finished],
      )

      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-elasticsearch', 'barito').and_return([]))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      get api_profile_curator_path,
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

      get api_profile_curator_path,
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

    it 'should not return list of all deleted app group' do
      app_group = create(:app_group)
      create(:barito_app, topic_name: 'deleted_topic1', app_group: app_group)
      infrastructure = create(:infrastructure, app_group: app_group, provisioning_status: Infrastructure.provisioning_statuses[:deleted] )
      create(
          :infrastructure_component,
          infrastructure: infrastructure,
          component_type: 'elasticsearch',
          status: InfrastructureComponent.statuses[:finished],
      )

      get api_profile_curator_path,
          params: { access_token: @access_token, client_key: 'abcd1234' },
          headers: headers

      expect(response.body).to eq [].to_json
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

        get api_authorize_path, params: { cluster_name: infrastructure.cluster_name, username: user_a[:username]  }, headers: headers

        expect(response.status).to eq 200
      end
    end

    context 'when invalid username or invalid cluster_name' do
      it 'should return 403' do
        app_group = create(:app_group)
        create(:infrastructure, app_group: app_group)

        get api_authorize_path, params: { cluster_name: "some-random-name", username: "some-user"  }, headers: headers

        expect(response.status).to eq 403
      end
    end

    context 'when valid username and cluster name but with inactive infrastructure' do
      it 'should return 403' do
        app_group = create(:app_group)
        infrastructure = create(:infrastructure, app_group: app_group)

        get api_authorize_path, params: { cluster_name: infrastructure.cluster_name, username: user_a.username  }, headers: headers

        expect(response.status).to eq 403
      end
    end
  end
end
