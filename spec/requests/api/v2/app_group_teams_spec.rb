require 'rails_helper'

RSpec.describe 'App Groups Teams API', type: :request do
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

  describe 'Create an app group team' do

    before(:each) do
        @group = create(:group, name: 'group_1')
        @app_group = create(:app_group, name:'app_group_1', secret_key: 'test_secret_key')
  
        @app_group_team_params = { access_token: @access_token, group_name: @group.name, app_group_secret: @app_group.secret_key }
      end

    context 'app group team creation is successful' do
        it 'return success response' do
            post api_v2_create_app_group_team_path params: @app_group_team_params, headers: headers

            expect(response.status).to eq 200
            json_response = JSON.parse(response.body)

            expect(json_response['data']).to eq(["AppGroup team created successfully"])
            expect(json_response['success']).to eq(true)

            expect(AppGroupTeam.first.app_group_id).to eq(@app_group.id)
            expect(AppGroupTeam.first.group_id).to eq(@group.id)
        end
    end

    context 'app group team creation unsuccessful' do
        it 'should return error status 422 when param AppGroup secret is not provided' do
            error_msg = 'Invalid Params: app_group_secret is a required parameter'
            post api_v2_create_app_group_team_path params: @app_group_team_params.except(:app_group_secret), headers: headers

            json_response = JSON.parse(response.body)
            expect(json_response['code']).to eq(422)
            expect(json_response['errors']).to eq([error_msg])
        end

        it 'should return error status 422 when param group name is not provided' do
            error_msg = 'Invalid Params: group_name is a required parameter'
            post api_v2_create_app_group_team_path params: @app_group_team_params.except(:group_name), headers: headers

            json_response = JSON.parse(response.body)
            expect(json_response['code']).to eq(422)
            expect(json_response['errors']).to eq([error_msg])
        end

        it 'should return error status 404 when AppGroup object is not found' do
            error_msg = 'AppGroup not found'
            app_group_test = @app_group_team_params
            app_group_test[:app_group_secret] = "test_secret_key_2"

            post api_v2_create_app_group_team_path params: app_group_test, headers: headers

            json_response = JSON.parse(response.body)
            expect(json_response['code']).to eq(404)
            expect(json_response['errors']).to eq([error_msg])
        end

        it 'should return error status 404 when group object is not found' do
            error_msg = 'Group not found'

            app_group_test = @app_group_team_params
            app_group_test[:group_name] = "group_2"

            post api_v2_create_app_group_team_path params: app_group_test, headers: headers

            json_response = JSON.parse(response.body)
            expect(json_response['code']).to eq(404)
            expect(json_response['errors']).to eq([error_msg])
        end
    end
  end
end
