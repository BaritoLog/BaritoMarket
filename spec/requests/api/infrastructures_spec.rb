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

    it 'should return list of all active App with its retention policy for curator' do
      app_group = create(:app_group)
      app1 = create(:barito_app, topic_name: 'topic1', app_group: app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      helm_infrastructure = create(:helm_infrastructure,
        app_group: app_group,
        provisioning_status: HelmInfrastructure.provisioning_statuses[:finished]
      )

      get api_profile_curator_path,
        params: { access_token: @access_token, client_key: 'abcd1234' },
        headers: headers

      expect(response.body).to eq [
        {
          ipaddress: helm_infrastructure.elasticsearch_address,
          log_retention_days: app_group.log_retention_days,
          log_retention_days_per_topic: {
            app2.topic_name => app2.log_retention_days
          },
        }
      ].to_json
    end

    it 'should get es ipaddress value helm_infrastructure es_address' do
      app_group = create(:app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished]
      )

      get api_profile_curator_path,
          params: { access_token: @access_token, client_key: 'abcd1234' },
          headers: headers

      expect(response.body).to eq [
        {
          ipaddress: helm_infrastructure.elasticsearch_address,
          log_retention_days: app_group.log_retention_days,
          log_retention_days_per_topic: {
            app2.topic_name => app2.log_retention_days
          },
        }
      ].to_json
    end

    it 'should return K8s Elasticsearch address' do
      app_group = create(:app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished],
        status: HelmInfrastructure.statuses[:active],
        is_active: true,
        use_k8s_kibana: true
      )

      get api_profile_curator_path,
          params: { access_token: @access_token, client_key: 'abcd1234' },
          headers: headers

          expect(JSON.parse(response.body)).to include({
            "ipaddress" => helm_infrastructure.elasticsearch_address,
            "log_retention_days" => app_group.log_retention_days,
            "log_retention_days_per_topic" => {
              app2.topic_name => app2.log_retention_days
            },
          })
    end

    it 'should works for DEPLOYMENT_FINISHED helm_infrastructures' do
      app_group = create(:app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      helm_infrastructure = create(:helm_infrastructure, 
        app_group: app_group, 
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished]
      )

      get api_profile_curator_path,
        params: { access_token: @access_token, client_key: 'abcd1234' },
        headers: headers

      expect(response.body).to eq [
        {
          ipaddress: helm_infrastructure.elasticsearch_address,
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
      helm_infrastructure = create(:helm_infrastructure,
        app_group: app_group,
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deleted]
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
        helm_infrastructure = create(:helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active])

        get api_authorize_path, params: { cluster_name: helm_infrastructure.cluster_name, username: user_a[:username]  }, headers: headers

        expect(response.status).to eq 200
      end
    end

    context 'when invalid username or invalid cluster_name' do
      it 'should return 403' do
        app_group = create(:app_group)
        create(:helm_infrastructure, app_group: app_group)

        get api_authorize_path, params: { cluster_name: "some-random-name", username: "some-user"  }, headers: headers

        expect(response.status).to eq 403
      end
    end

    context 'when valid username and cluster name but with inactive helm_infrastructure' do
      it 'should return 403' do
        app_group = create(:app_group)
        helm_infrastructure = create(:helm_infrastructure, app_group: app_group)

        get api_authorize_path, params: { cluster_name: helm_infrastructure.cluster_name, username: user_a.username  }, headers: headers

        expect(response.status).to eq 403
      end
    end
  end
end
