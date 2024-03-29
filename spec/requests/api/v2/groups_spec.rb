require 'rails_helper'

RSpec.describe 'Group API', type: :request do
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

  describe 'Create group API' do
    context 'When no group name is provided' do
      it 'should return 422' do
        error_msg = 'Invalid Params: name field is required'

        post api_v2_create_group_path, params: { 
          access_token: @access_token
          }, headers: headers
        
        expect(response.status).to eq 422
      end
    end

    context 'When group name is provided but its already present' do
      it 'should return existing group data' do
        group_name = 'test_group'
        group = create(:group, name: group_name)

        post api_v2_create_group_path, params: { 
          access_token: @access_token,
          name: group_name
          }, headers: headers

        expect(response.status).to eq 200
        json_response = JSON.parse(response.body)
        expect(json_response['data']['name']).to eq(group_name)
        expect(json_response['data']['id']).to eq(group.id)
      end
    end

    context 'When group name is provided and it does not already exists' do
      it 'should return newly created group' do
        group_name = 'test_group'

        post api_v2_create_group_path, params: { 
          access_token: @access_token,
          name: group_name
          }, headers: headers

        expect(response.status).to eq 200
        group = Group.find_by(name: group_name)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['name']).to eq(group.name)
        expect(json_response['data']['id']).to eq(group.id)
      end
    end
  end

  describe 'Check existing group API' do

    before(:each) do
      @group = create(:group, name: 'group_1')
    end

    context 'When group name is not provided' do
      it 'should return 422' do
        error_msg = 'Invalid Params: name is a required parameter'

        get api_v2_check_group_path, params: {
          access_token: @access_token
          }, headers: headers

        expect(response.status).to eq(422)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq([error_msg])
      end
    end

    context 'When group name is provided and it does not already exists' do
      it 'should return 404' do
        error_msg = 'Group not found'
        group_name = 'group_2'

        get api_v2_check_group_path, params: {
          access_token: @access_token,
          name: group_name
          }, headers: headers

        json_response = JSON.parse(response.body)
        expect(json_response['code']).to eq(404)
        expect(json_response['errors']).to eq([error_msg])
      end
    end

    context 'When group name is provided and it already exists' do
      it 'should return the existing group data' do
        group_name = 'group_1'

        get api_v2_check_group_path, params: {
          access_token: @access_token,
          name: group_name
          }, headers: headers

        expect(response.status).to eq 200
        json_response = JSON.parse(response.body)
        expect(json_response['data']['name']).to eq(@group.name)
        expect(json_response['data']['id']).to eq(@group.id)
      end
    end
  end
end
