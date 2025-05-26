require 'rails_helper'

RSpec.describe 'App API', type: :request do
  before(:all) do
    @access_token = 'ABC123'
    @ext_app = create(:ext_app, access_token: @access_token)
  end

  after(:all) do
    @ext_app.destroy
  end

  let(:default_infrastructure_location) { create(:infrastructure_location, name: Figaro.env.default_infrastructure_location) }

  describe 'Get Helm Infrastructures' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return 404 if cluster_name does not exists' do
      get api_v3_helm_infrastructures_by_cluster_name_path,
        params: { access_token: @access_token},
        headers: headers
      json_response = JSON.parse(response.body)

      expect(response.status).to eq 404
    end

    it 'should return specific helm infrastructures along with its location based on cluster_name' do
      app_group = create(:app_group)
      hi1 = create(
        :helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active], cluster_name: app_group.cluster_name
      )
      hi2 = create(
        :helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active], cluster_name: app_group.cluster_name
      )
      get api_v3_helm_infrastructures_by_cluster_name_path,
        params: { access_token: @access_token, cluster_name: app_group.cluster_name},
        headers: headers

      json_response = JSON.parse(response.body)

      expect(response.status).to eq 200
      expect(json_response.length).to eq 2
      expect(json_response.pluck("id")).to eq [hi1.id, hi2.id]
      expect(json_response.pluck("cluster_name")).to eq [app_group.cluster_name, app_group.cluster_name]
      expect(json_response[0]["infrastructure_location"]["name"]).to eq hi1.infrastructure_location.name
      expect(json_response[1]["infrastructure_location"]["name"]).to eq hi2.infrastructure_location.name
    end
  end

  describe 'Update Helm Manifest' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    let!(:app_group) { create(:app_group) }
    let!(:location) { create(:infrastructure_location, name: 'main-dc') }

    it 'should return 404 if cluster_name does not exists' do
      patch api_v3_update_helm_manifest_by_cluster_name_path,
        params: { access_token: @access_token, location_name: location.name, cluster_name: 'abc'},
        headers: headers
      json_response = JSON.parse(response.body)

      expect(response.status).to eq 404
    end

    it 'should return 404 if location does not exists' do
      helm_infrastructure = create(:helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active])
      patch api_v3_update_helm_manifest_by_cluster_name_path,
        params: { access_token: @access_token, cluster_name: app_group.cluster_name, location_name: 'abc'},
        headers: headers
      json_response = JSON.parse(response.body)

      expect(response.status).to eq 404
    end

    it 'should return 400 if the payload is not a proper json' do
      app_group = create(:app_group)
      helm_infrastructure = create(
        :helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active],
        infrastructure_location_id: location.id
      )
      patch api_v3_update_helm_manifest_by_cluster_name_path,
        params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          location_name: location.name
        },
        headers: headers
      expect(response.status).to eq 400
    end

    it 'should update the override_values HelmInfrastructure with matching cluster_name & location_name' do
      app_group = create(:app_group)
      helm_infrastructure = create(
        :helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active], infrastructure_location_id: location.id
      )

      override_values = {
        "producer" => {
          "number_of_replicas" => "1",
        }
      }

      patch api_v3_update_helm_manifest_by_cluster_name_path,
        params: {
          access_token: @access_token, cluster_name: app_group.cluster_name,
          location_name: location.name, override_values: override_values,
        },
        headers: headers
      expect(response.status).to eq 200
      update_object =  app_group.reload.helm_infrastructures.first
      expect(update_object.override_values).to eq override_values
    end

    it 'should not update the override_values HelmInfrastructure if not matching cluster_name & location_name' do
      app_group = create(:app_group)
      location2 = create(:infrastructure_location, name: 'secondary-dc')
      helm_infrastructure = create(
        :helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active], infrastructure_location_id: location.id
      )
      not_matches = [
        create(:helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active], infrastructure_location_id: location2.id),
        create(:helm_infrastructure, status: HelmInfrastructure.statuses[:active], infrastructure_location_id: location.id)
      ]

      override_values = {
        "producer" => {
          "number_of_replicas" => "1",
        }
      }

      patch api_v3_update_helm_manifest_by_cluster_name_path,
        params: {
          access_token: @access_token, cluster_name: app_group.cluster_name,
          location_name: location.name, override_values: override_values,
        },
        headers: headers
      expect(response.status).to eq 200
      update_object =  app_group.reload.helm_infrastructures.first
      expect(update_object.override_values).to eq override_values
      not_matches.each do |not_match|
        expect(not_match.override_values).to eq({})
      end
    end


  end

  describe 'Sync Helm Manifest' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    let!(:app_group) { create(:app_group) }
    let!(:location) { create(:infrastructure_location, name: 'main-dc') }

    it 'should return 404 if cluster_name does not exists' do
      post api_v3_sync_helm_infrastructure_by_cluster_name_path,
        params: { access_token: @access_token, location_name: location.name, cluster_name: 'abc'},
        headers: headers
      json_response = JSON.parse(response.body)

      expect(response.status).to eq 404
    end

    it 'should return 404 if location does not exists' do
      helm_infrastructure = create(:helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active])
      post api_v3_sync_helm_infrastructure_by_cluster_name_path,
        params: { access_token: @access_token, cluster_name: app_group.cluster_name, location_name: 'abc'},
        headers: headers
      json_response = JSON.parse(response.body)

      expect(response.status).to eq 404
    end
  end

  describe 'Profile by App Group Name API' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end
    let!(:app_group) { create(:app_group) }

    it 'should return profile information of registered app when supplied appgroup name' do
      3.times do
        create(:helm_infrastructure, :active, app_group: app_group)
      end
      get api_v3_profile_by_app_group_name_path,
        params: { access_token: @access_token, app_group_name: app_group.name },
        headers: headers
      json_response = JSON.parse(response.body)

      %w[name id secret_key cluster_name kibana_address status]
        .each do |key|
          expect(json_response.key?(key)).to eq(true)
          expect(json_response[key]).to eq(app_group.send(key.to_sym))
        end

      expect(json_response['infrastructures'].length).to eq(3)
      expect(json_response.key?('updated_at')).to eq(true)
      expect(json_response.key?('created_at')).to eq(true)
    end

    context 'when app_group inactive' do
      it 'should return 404' do
        error_msg = 'App Group not found'
        inactive_app_group = create(:app_group, status: AppGroup.statuses[:inactive])

        get api_v3_profile_by_app_group_name_path,
          params: { access_token: @access_token, app_group_name: inactive_app_group.name },
          headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq false
        expect(json_response['code']).to eq 404
        expect(json_response['errors']).to eq [error_msg]
      end
    end


  end

  describe 'Profile by Cluster Name API' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end
    let(:app_group) { create(:app_group) }

    it 'should return profile information of registered app when supplied cluster name' do
      3.times do
        create(:helm_infrastructure, :active, app_group: app_group)
      end
      get api_v3_profile_by_cluster_name_path,
        params: { access_token: @access_token, cluster_name: app_group.cluster_name },
        headers: headers
      json_response = JSON.parse(response.body)

      %w[name id secret_key cluster_name kibana_address status producer_location kibana_location]
        .each do |key|
          expect(json_response.key?(key)).to eq(true)
          expect(json_response[key]).to eq(app_group.send(key.to_sym))
        end

      expect(json_response['infrastructures'].length).to eq(3)
      expect(json_response.key?('updated_at')).to eq(true)
      expect(json_response.key?('created_at')).to eq(true)
    end

    context 'when app_group inactive' do
      it 'should return 404' do
        error_msg = 'App Group not found'
        inactive_app_group = create(:app_group, status: AppGroup.statuses[:inactive])

        get api_v3_profile_by_cluster_name_path,
          params: { access_token: @access_token, cluster_name: inactive_app_group.cluster_name },
          headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq false
        expect(json_response['code']).to eq 404
        expect(json_response['errors']).to eq [error_msg]
      end
    end

  end

  describe 'List Profile' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return list profile information of registered appgroups' do
      app_group = create(:app_group)

      get api_v3_profile_index_path,
        params: { access_token: @access_token},
        headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response.length).to eq(1)
      j = json_response[0]
      %w[name secret_key cluster_name status].
        each do |key|
          expect(j.key?(key)).to eq(true)
          expect(j[key]).to eq(app_group.send(key.to_sym))
        end
    end

    it 'should return paginated response' do
      app_groups = []
      12.times do |i|
        app_group = create(:app_group)
        app_groups << app_group
      end

      get api_v3_profile_index_path,
        params: { access_token: @access_token},
        headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(10)

      get api_v3_profile_index_path,
        params: { access_token: @access_token, page: 2},
        headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)

      get api_v3_profile_index_path,
        params: { access_token: @access_token, limit: 20},
        headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(12)
    end
  end

  describe 'Authorize API' do
    let(:user_a) { create(:user) }
    let(:role) { AppGroupRole.create(name: 'admin') }

    it 'should return 403 if appgroup not exists' do
      login_as user_a

      get api_v3_authorize_path, params: {
        access_token: @access_token,
        cluster_name: 'some-random-name',
        username: user_a[:username],
      }, headers: headers

      expect(response.status).to eq 403
    end

    context 'when using barito-superadmin group' do
      let!(:group_user) { GroupUser.create(user: user_a, group: Group.find_by_name('barito-superadmin'), role: role, expiration_date: (Time.now + 1.days)) }
      it 'should return 200' do
        app_group = create(:app_group)

        get api_v3_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 200
      end

      it 'should return 403 if the AppGroup are Inactive' do
        app_group = create(:app_group, status: :INACTIVE)

        get api_v3_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 403
      end

      it 'should return 403 if expired' do
        user_a.group_users.first.update(expiration_date: (Time.now - 1.days))
        app_group = create(:app_group)

        get api_v3_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 403
      end
    end

    context 'when username are included in the AppGroupUser' do
      it 'should return 200' do
        app_group = create(:app_group)
        AppGroupUser.create(app_group: app_group, user: user_a, role: role, expiration_date: Time.now..Float::INFINITY)

        get api_v3_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 200
      end

      it 'should return 403 if the AppGroup are Inactive' do
        app_group = create(:app_group, status: :INACTIVE)
        AppGroupUser.create(app_group: app_group, user: user_a, role: role, expiration_date: Time.now..Float::INFINITY)

        get api_v3_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 403
      end

      it 'should return 403 if expired' do
        app_group = create(:app_group)
        AppGroupUser.create(app_group: app_group, user: user_a, role: role, expiration_date: (Time.now - 1.days))

        get api_v3_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 403
      end

      it 'should return 403 if used different app_group cluster_name' do
        app_group = create(:app_group)
        app_group2 = create(:app_group)
        AppGroupUser.create(app_group: app_group, user: user_a, role: role, expiration_date: (Time.now - 1.days))

        get api_v3_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group2.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 403
      end
    end

    context 'when invalid username' do
      it 'should return 403' do
        app_group = create(:app_group)

        get api_v3_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: 'some-user',
        }, headers: headers

        expect(response.status).to eq 403
      end
    end

  end

  describe 'Profile for Curator' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return list of all active App with its retention policy for curator' do
      app_group = create(:app_group)
      app1 = create(:barito_app, topic_name: 'topic1', app_group: app_group, log_retention_days: nil)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      helm_infrastructure = create( :helm_infrastructure,
        app_group: app_group,
        provisioning_status: HelmInfrastructure.provisioning_statuses[:finished],
        cluster_name: app_group.cluster_name
      )

      get api_v3_profile_curator_path,
        params: { access_token: @access_token, client_key: 'abcd1234' },
        headers: headers

      expect(response.body).to eq [
        {
          ipaddress: app_group.elasticsearch_address,
          log_retention_days: app_group.log_retention_days,
          log_retention_days_per_topic: {
            app2.topic_name => app2.log_retention_days
          },
        }
      ].to_json
    end

    it "should not return appgroup that didn't have finished helm_infrastructure provisioning_status" do
      app_group = create(:app_group)
      helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        provisioning_status: HelmInfrastructure.provisioning_statuses[:pending],
        cluster_name: app_group.cluster_name
      )

      get api_v3_profile_curator_path,
        params: { access_token: @access_token, client_key: 'abcd1234' },
        headers: headers


      expect(JSON.parse(response.body)).to eq([])
    end

    it 'should also works for DEPLOYMENT_FINISHED infrastructures' do
      app_group = create(:app_group)
      app1 = create(:barito_app, topic_name: 'topic1', app_group: app_group, log_retention_days: nil)
      helm_infrastructure = create( :helm_infrastructure,
        app_group: app_group,
        provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished],
        cluster_name: app_group.cluster_name
      )

      get api_v3_profile_curator_path,
        params: { access_token: @access_token, client_key: 'abcd1234' },
        headers: headers

      expect(response.body).to eq [
        {
          ipaddress: app_group.elasticsearch_address,
          log_retention_days: app_group.log_retention_days,
          log_retention_days_per_topic: {},
        }
      ].to_json
    end
  end

  describe 'Profile for Curator by cluster_name' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return retention policy for the requested ap group' do
      app_group = create(:app_group)
      app1 = create(:barito_app, topic_name: 'topic1', app_group: app_group, log_retention_days: nil)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      helm_infrastructure = create( :helm_infrastructure,
        app_group: app_group,
        provisioning_status: HelmInfrastructure.provisioning_statuses[:finished],
        cluster_name: app_group.cluster_name
      )

      get api_v3_profile_curator_by_cluster_name_path,
        params: { cluster_name: app_group.cluster_name, access_token: @access_token, client_key: 'abcd1234' },
        headers: headers

      expected_response = {
        log_retention_days: app_group.log_retention_days,
        log_retention_days_per_topic: {
          app2.topic_name => app2.log_retention_days
        },
      }
      expect(response.status).to eq 200
      expect(response.content_type).to eq 'application/json'
      expect(response.body).to eq expected_response.to_json
    end

    it 'should return 404 if the appgroup not exists ' do
      get api_v3_profile_curator_by_cluster_name_path,
        params: {cluster_name: 'no-exists', access_token: @access_token, client_key: 'abcd1234' },
        headers: headers

      expect(response.status).to eq 404
      expect(response.content_type).to eq 'application/json'
      expect(JSON.parse(response.body)).to eq({
        'success' => false,
        'errors' => ['App Group not found'],
        'code' => 404
      })
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

      get api_v3_profile_prometheus_exporter_path,
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
end
