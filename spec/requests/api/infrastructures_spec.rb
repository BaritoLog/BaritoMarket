require 'rails_helper'

RSpec.describe 'App API', type: :request do

  describe 'Authorize API' do
    let(:user_a) { create(:user) }
    let(:role) { AppGroupRole.create(name: 'admin') }

    it 'should return 403 if appgroup not exists' do
      login_as user_a

      get api_authorize_path, params: {
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

        get api_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 200
      end

      it 'should return 403 if the AppGroup are Inactive' do
        app_group = create(:app_group, status: :INACTIVE)

        get api_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 403
      end

      it 'should return 403 if expired' do
        user_a.group_users.first.update(expiration_date: (Time.now - 1.days))
        app_group = create(:app_group)

        get api_authorize_path, params: {
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

        get api_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 200
      end

      it 'should return 403 if the AppGroup are Inactive' do
        app_group = create(:app_group, status: :INACTIVE)
        AppGroupUser.create(app_group: app_group, user: user_a, role: role, expiration_date: Time.now..Float::INFINITY)

        get api_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: user_a[:username],
        }, headers: headers

        expect(response.status).to eq 403
      end

      it 'should return 403 if expired' do
        app_group = create(:app_group)
        AppGroupUser.create(app_group: app_group, user: user_a, role: role, expiration_date: (Time.now - 1.days))

        get api_authorize_path, params: {
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

        get api_authorize_path, params: {
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

        get api_authorize_path, params: {
          access_token: @access_token,
          cluster_name: app_group.cluster_name,
          username: 'some-user',
        }, headers: headers

        expect(response.status).to eq 403
      end
    end
  end
end
