require 'rails_helper'

RSpec.describe 'App API', type: :request do
  before(:all) do
    @access_token = 'ABC123'
    @ext_app = create(:ext_app, access_token: @access_token)
  end

  after(:all) do
    @ext_app.destroy
  end

  # describe 'List Profile' do
  #   let(:headers) do
  #     { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
  #   end

  #   it 'should return list profile information of registered appgroups' do
  #     HelmInfrastructure.delete_all

  #     app_group = create(:app_group)
  #     helm_infrastructure = create(
  #       :helm_infrastructure,
  #       app_group: app_group,
  #       status: HelmInfrastructure.statuses[:active],
  #       provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished]
  #     )

  #     get api_v2_profile_index_path,
  #       params: { access_token: @access_token},
  #       headers: headers
  #     json_response = JSON.parse(response.body)

  #     expect(json_response.length).to eq(1)
  #     j = json_response[0]
  #     %w[cluster_name status provisioning_status].
  #       each do |key|
  #         expect(j.key?(key)).to eq(true)
  #         expect(j[key]).to eq(app_group.helm_infrastructure.send(key.to_sym))
  #       end
  #       expect(j['name']).to eq(helm_infrastructure.app_group_name)
  #       expect(j['app_group_name']).to eq(helm_infrastructure.app_group_name)
  #   end

  #   it 'should return paginated response' do
  #     HelmInfrastructure.delete_all
  #     helm_cluster_template = create(:helm_cluster_template)
  #     app_groups = []
  #     12.times do |i|
  #       app_group = create(:app_group)
  #       helm_infrastructure = create(
  #         :helm_infrastructure,
  #         app_group: app_group,
  #         status: HelmInfrastructure.statuses[:active],
  #         provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished],
  #         helm_cluster_template: helm_cluster_template
  #       )
  #       app_groups << app_group
  #     end

  #     get api_v2_profile_index_path,
  #       params: { access_token: @access_token},
  #       headers: headers
  #     json_response = JSON.parse(response.body)
  #     expect(json_response.length).to eq(10)

  #     get api_v2_profile_index_path,
  #       params: { access_token: @access_token, page: 2},
  #       headers: headers
  #     json_response = JSON.parse(response.body)
  #     expect(json_response.length).to eq(2)

  #     get api_v2_profile_index_path,
  #       params: { access_token: @access_token, limit: 20},
  #       headers: headers
  #     json_response = JSON.parse(response.body)
  #     expect(json_response.length).to eq(12)
  #   end
  # end

  # describe 'Profile by Cluster Name API' do
  #   let(:headers) do
  #     { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
  #   end

  #   it 'should return profile information of registered app when supplied cluster name' do
  #     app_group = create(:app_group)
  #     helm_infrastructure = create(
  #       :helm_infrastructure,
  #       app_group: app_group,
  #       status: HelmInfrastructure.statuses[:active]
  #     )

  #     get api_v2_profile_by_cluster_name_path,
  #       params: { access_token: @access_token, cluster_name: helm_infrastructure.cluster_name },
  #       headers: headers
  #     json_response = JSON.parse(response.body)

  #     %w[cluster_name status provisioning_status].
  #       each do |key|
  #         expect(json_response.key?(key)).to eq(true)
  #         expect(json_response[key]).to eq(helm_infrastructure.send(key.to_sym))
  #       end

  #     expect(json_response['name']).to eq(helm_infrastructure.app_group_name)
  #     expect(json_response['app_group_name']).to eq(helm_infrastructure.app_group_name)
  #     expect(json_response['app_group_secret']).to eq(helm_infrastructure.app_group_secret)
  #     expect(json_response['capacity']).to eq(helm_infrastructure.helm_cluster_template.name)
  #     expect(json_response.key?('updated_at')).to eq(true)
  #     expect(json_response['kibana_address']).to eq(helm_infrastructure.kibana_address)
  #   end

  #   it 'should return K8s Kibana if activated' do
  #     app_group = create(:app_group)
  #     helm_infrastructure = create(:helm_infrastructure,
  #       app_group: app_group,
  #       status: HelmInfrastructure.statuses[:active],
  #       cluster_name: 'haza',
  #     )

  #     get api_v2_profile_by_cluster_name_path,
  #       params: { access_token: @access_token, cluster_name: helm_infrastructure.cluster_name },
  #       headers: headers
  #     json_response = JSON.parse(response.body)

  #     expect(json_response['kibana_address']).to eq("#{helm_infrastructure.cluster_name}-kb-http.barito-worker.svc:5601")
  #     expect(json_response['kibana_address']).to eq(helm_infrastructure.kibana_address)
  #   end

  #   context 'when infrastructure inactive' do
  #     it 'should return 404' do
  #       error_msg = 'Infrastructure not found'
  #       app_group = create(:app_group)
  #       helm_infrastructure = create(:helm_infrastructure, app_group: app_group)

  #       get api_v2_profile_by_cluster_name_path,
  #         params: { access_token: @access_token, cluster_name: helm_infrastructure.cluster_name },
  #         headers: headers
  #       json_response = JSON.parse(response.body)

  #       expect(json_response['success']).to eq false
  #       expect(json_response['code']).to eq 404
  #       expect(json_response['errors']).to eq [error_msg]
  #     end
  #   end
  # end

  describe 'Profile by App Group Name API' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return profile information of registered app when supplied cluster name' do
      app_group = create(:app_group)
      helm_infrastructure = create(
        :helm_infrastructure,
        app_group: app_group,
        status: HelmInfrastructure.statuses[:active]
      )

      get api_v2_profile_by_app_group_name_path,
        params: { access_token: @access_token, app_group_name: app_group.name },
        headers: headers
      json_response = JSON.parse(response.body)

      %w[cluster_name status provisioning_status].
        each do |key|
          expect(json_response.key?(key)).to eq(true)
          expect(json_response[key]).to eq(helm_infrastructure.send(key.to_sym))
        end

      expect(json_response['app_group_name']).to eq(helm_infrastructure.app_group_name)
      expect(json_response['app_group_secret']).to eq(helm_infrastructure.app_group_secret)
      expect(json_response['capacity']).to eq(helm_infrastructure.helm_cluster_template.name)
      expect(json_response.key?('updated_at')).to eq(true)
      expect(json_response['kibana_address']).to eq(helm_infrastructure.kibana_address)
    end

    it 'should return K8s Kibana if activated' do
      app_group = create(:app_group)
      helm_infrastructure = create(:helm_infrastructure,
        app_group: app_group,
        status: HelmInfrastructure.statuses[:active],
        cluster_name: 'haza',
      )

      get api_v2_profile_by_app_group_name_path,
        params: { access_token: @access_token, app_group_name: app_group.name },
        headers: headers
      json_response = JSON.parse(response.body)

      expect(json_response['kibana_address']).to eq("#{helm_infrastructure.cluster_name}-kb-http.barito-worker.svc:5601")
      expect(json_response['kibana_address']).to eq(helm_infrastructure.kibana_address)
    end

    context 'when App Group unavailable' do
      it 'should return 404' do
        error_msg = 'App Group not found'
        app_group = create(:app_group)
        helm_infrastructure = create(:helm_infrastructure, app_group: app_group)

        get api_v2_profile_by_app_group_name_path,
          params: { access_token: @access_token, app_group_name: app_group.name },
          headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq false
        expect(json_response['code']).to eq 404
        expect(json_response['errors']).to eq [error_msg]
      end
    end
  end

  # describe 'Profile for Curator' do
  #   let(:headers) do
  #     { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
  #   end

  #   it 'should return list of all active App with its retention policy for curator' do
  #     app_group = create(:app_group)
  #     app1 = create(:barito_app, topic_name: 'topic1', app_group: app_group)
  #     app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
  #     helm_infrastructure = create(:helm_infrastructure, app_group: app_group, provisioning_status: HelmInfrastructure.provisioning_statuses[:finished])

  #     get api_v2_profile_curator_path,
  #       params: { access_token: @access_token, client_key: 'abcd1234' },
  #       headers: headers

  #     expect(response.body).to eq [
  #       {
  #         ipaddress: helm_infrastructure.elasticsearch_address,
  #         log_retention_days: app_group.log_retention_days,
  #         log_retention_days_per_topic: {
  #           app2.topic_name => app2.log_retention_days
  #         },
  #       }
  #     ].to_json
  #   end

  #   it 'should return K8s Elasticsearch address' do
  #     app_group = create(:app_group)
  #     app1 = create(:barito_app, topic_name: 'topic1', app_group: app_group)
  #     app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
  #     helm_infrastructure = create(
  #       :helm_infrastructure,
  #       app_group: app_group,
  #       provisioning_status: HelmInfrastructure.provisioning_statuses[:finished]
  #     )

  #     get api_v2_profile_curator_path,
  #       params: { access_token: @access_token, client_key: 'abcd1234' },
  #       headers: headers

  #     expect(JSON.parse(response.body)).to include({
  #       "ipaddress" => "#{helm_infrastructure.cluster_name}-es-http.barito-worker.svc",
  #       "log_retention_days" => app_group.log_retention_days,
  #       "log_retention_days_per_topic" => {
  #         app2.topic_name => app2.log_retention_days
  #       },
  #     })
  #   end

  #   it 'should works for DEPLOYMENT_FINISHED infrastructures' do
  #     app_group = create(:app_group)
  #     app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
  #     helm_infrastructure = create(:helm_infrastructure, app_group: app_group, provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished])

  #     get api_v2_profile_curator_path,
  #       params: { access_token: @access_token, client_key: 'abcd1234' },
  #       headers: headers

  #     expect(response.body).to eq [
  #       {
  #         ipaddress: helm_infrastructure.elasticsearch_address,
  #         log_retention_days: app_group.log_retention_days,
  #         log_retention_days_per_topic: {
  #           app2.topic_name => app2.log_retention_days
  #         },
  #       }
  #     ].to_json
  #   end
  # end

  # describe 'Profile for Prometheus Exporters' do
  #   let(:headers) do
  #     { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
  #   end

  #   it 'should return list of all infrastructure components with environment label' do
  #     app_group_a = create(:app_group, environment: AppGroup.environments[:staging])
  #     infrastructure_a = create(:infrastructure, app_group: app_group_a)
  #     infrastructure_component_a = create(
  #       :infrastructure_component, infrastructure: infrastructure_a,
  #                                  status: InfrastructureComponent.statuses[:finished]
  #     )

  #     get api_v2_profile_prometheus_exporter_path,
  #       params: { access_token: @access_token }, headers: headers

  #     expect(response.body).to eq [
  #       {
  #         cluster_name: infrastructure_a.cluster_name,
  #         component_type: infrastructure_component_a.component_type,
  #         environment: app_group_a.environment,
  #         ipaddress: infrastructure_component_a.ipaddress,
  #       }
  #     ].to_json
  #   end
  # end

  # describe 'Authorize API' do
  #   let(:user_a) { create(:user) }

  #   context 'when valid username and valid cluster_name' do
  #     it 'should return 200' do
  #       set_check_user_groups('groups': ['barito-superadmin'])
  #       login_as user_a
  #       create(:group, name: 'barito-superadmin')
  #       app_group = create(:app_group)
  #       helm_infrastructure = create(
  #         :helm_infrastructure, app_group: app_group, status: HelmInfrastructure.statuses[:active]
  #       )

  #       get api_v2_authorize_path, params: {
  #         access_token: @access_token,
  #         cluster_name: helm_infrastructure.cluster_name,
  #         username: user_a[:username],
  #       }, headers: headers

  #       expect(response.status).to eq 200
  #     end
  #   end

  #   context 'when invalid username or invalid cluster_name' do
  #     it 'should return 403' do
  #       app_group = create(:app_group)
  #       create(:helm_infrastructure, app_group: app_group)

  #       get api_v2_authorize_path, params: {
  #         access_token: @access_token,
  #         cluster_name: 'some-random-name',
  #         username: 'some-user',
  #       }, headers: headers

  #       expect(response.status).to eq 403
  #     end
  #   end

  #   context 'when valid username and cluster name but with inactive infrastructure' do
  #     it 'should return 403' do
  #       app_group = create(:app_group)
  #       helm_infrastructure = create(:helm_infrastructure, app_group: app_group)

  #       get api_v2_authorize_path, params: {
  #         access_token: @access_token,
  #         cluster_name: helm_infrastructure.cluster_name,
  #         username: user_a.username,
  #       }, headers: headers

  #       expect(response.status).to eq 403
  #     end
  #   end
  # end
end
