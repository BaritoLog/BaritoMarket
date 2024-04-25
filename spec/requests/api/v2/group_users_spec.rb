require 'rails_helper'

RSpec.describe 'Groups User API', type: :request do
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

  describe 'Create a group user' do
    before(:each) do
      @group = create(:group, name: 'group_1')
      @user = create(:user)
      @role = create(:app_group_role, :admin)

      @group_user_params = { access_token: @access_token, group_name: @group.name, group_role: @role.name, username: @user.username }
    end
    context 'group user creation successful' do
      it 'returns success response' do
        post api_v2_create_group_user_path, params: @group_user_params, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to eq(["Group user created"])
        expect(json_response['success']).to eq(true)

        expect(GroupUser.first.group_id).to eq(@group.id)
        expect(GroupUser.first.role.id).to eq(@role.id)
        expect(GroupUser.first.user_id).to eq(@user.id)
        expect(GroupUser.first.expiration_date).to eq(nil)
      end

      it 'should handle expiration_date param' do
        expiration_date = '2024-01-01'
        with_expiration_date = { access_token: @access_token, group_name: @group.name, group_role: @role.name, username: @user.username, expiration_date: expiration_date}
        post api_v2_create_group_user_path, params: with_expiration_date, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to eq(["Group user created"])
        expect(json_response['success']).to eq(true)

        expect(GroupUser.first.group_id).to eq(@group.id)
        expect(GroupUser.first.role.id).to eq(@role.id)
        expect(GroupUser.first.user_id).to eq(@user.id)
        expect(GroupUser.first.expiration_date).to eq(expiration_date)
      end
    end

    context 'group user creation unsuccessful' do
      it 'when params group name is not provided it should return 422' do
        error_msg = 'Invalid Params: group_name is a required parameter'
        post api_v2_create_group_user_path, params: @group_user_params.except(:group_name), headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq(422)
        expect(json_response['errors']).to eq([error_msg])
      end

      it 'when username is not provided it should return 422' do
        error_msg = 'Invalid Params: username is a required parameter'
        post api_v2_create_group_user_path, params: @group_user_params.except(:username), headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq(422)
        expect(json_response['errors']).to eq([error_msg])
      end

      it 'when group_role is not provided it should return 422' do
        error_msg = 'Invalid Params: group_role is a required parameter'
        post api_v2_create_group_user_path, params: @group_user_params.except(:group_role), headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['code']).to eq(422)
        expect(json_response['errors']).to eq([error_msg])
      end

      it 'when group user creation fails' do
        allow_any_instance_of(GroupUser).to receive(:valid?).and_return(false)
        allow_any_instance_of(GroupUser).to receive(:errors).and_return('some error')

        post api_v2_create_group_user_path, params: @group_user_params, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to eq(false)
        expect(json_response['errors']).to eq(['some error'])
      end
    end
  end
end
