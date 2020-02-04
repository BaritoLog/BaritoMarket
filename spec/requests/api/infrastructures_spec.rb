require 'rails_helper'

RSpec.describe 'App API', type: :request do
  describe 'Profile for Curator' do
    let(:headers) do
      { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
    end

    it 'should return list of all active App with its retention policy for curator' do
      app_group = create(:app_group)
      app1 = create(:barito_app, topic_name: 'topic1', app_group: app_group)
      app2 = create(:barito_app, topic_name: 'topic2', app_group: app_group, log_retention_days: 1200)
      infrastructure = create(:infrastructure, app_group: app_group)
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
            app1.topic_name => app_group.log_retention_days,
            app2.topic_name => app2.log_retention_days
          },
        }
      ].to_json
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
