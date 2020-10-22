require 'rails_helper'

RSpec.describe 'App Groups User API', type: :request do
  let(:headers) do
    { 'ACCEPT' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }
  end

  before(:all) do
    @access_token = 'ABC123'
    @ext_app = create(:ext_app, access_token: @access_token)
  end

  after(:all) do
    @ext_app.destroy
  end


  describe 'Create an app group user' do
    let(:app_group) { create(:app_group) }
    let(:user) { create(:user) }
    let(:role) { create(:app_group_role, :admin) }
    let(:app_group_user_params) { { access_token: @access_token, app_group_secret: app_group.secret_key, app_group_role: role.name, user_email: user.email } }

    context 'app group user creation successful' do
      it 'returns success response' do

        post api_v2_create_app_group_user_path, params: app_group_user_params, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to eq(["App group user created"])
        expect(json_response['success']).to eq(true)

        expect(AppGroupUser.first.app_group_id).to eq(app_group.id)
        expect(AppGroupUser.first.role.id).to eq(role.id)
        expect(AppGroupUser.first.user_id).to eq(user.id)
      end
    end

    context 'app group user creation unsuccessful' do
      it 'when appgroup secret is not provided it should return 422' do
        error_msg = 'Invalid Params: app_group_secret is a required parameter'
        post api_v2_create_app_group_user_path, params: app_group_user_params.except(:app_group_secret), headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq(422)
        expect(json_response['errors']).to eq([error_msg])
      end

      it 'when user email is not provided it should return 422' do
        error_msg = 'Invalid Params: user_email is a required parameter'
        post api_v2_create_app_group_user_path, params: app_group_user_params.except(:user_email), headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq(422)
        expect(json_response['errors']).to eq([error_msg])
      end

      it 'when app_group_role is not provided it should return 422' do
        error_msg = 'Invalid Params: app_group_role is a required parameter'
        post api_v2_create_app_group_user_path, params: app_group_user_params.except(:app_group_role), headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq(422)
        expect(json_response['errors']).to eq([error_msg])
      end

      it 'when app group user creation fails' do
        allow_any_instance_of(AppGroupUser).to receive(:valid?).and_return(false)
        allow_any_instance_of(AppGroupUser).to receive(:errors).and_return('some error')

        post api_v2_create_app_group_user_path, params: app_group_user_params, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq(false)
        expect(json_response['errors']).to eq(['some error'])
      end
    end
  end
end
