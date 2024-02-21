require 'rails_helper'

RSpec.describe AppsController, type: :controller do
  let(:helm_infrastructure) { create(:helm_infrastructure) }
  let(:app_group) { helm_infrastructure.app_group }
  let(:app) { create(:barito_app, app_group: app_group) }

  let(:user) { create(:user) }

  describe 'update' do
    context 'as superadmin' do
      before :each do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        sign_in user
      end

      it 'is not updating log_retention_days parameter' do
        app.update(log_retention_days: 14)
        post :update, params: { id: app.id, barito_app: { log_retention_days: 10 } }

        app.reload
        expect(app.log_retention_days).to eq(14)
      end
    end
  end

  describe 'update_log_retention_days' do
    context 'as superadmin' do
      before :each do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        sign_in user
      end

      it 'updates log_retention_days' do
        app.update(log_retention_days: 14)
        post :update_log_retention_days, params: { id: app.id, barito_app: { log_retention_days: 10 } }

        app.reload
        expect(app.log_retention_days).to eq(10)
      end
    end

    context 'as owner' do
      before :each do
        set_check_user_groups({ 'groups' => [] })

        role_owner = create(:app_group_role, :owner)
        create(:app_group_user, user: user, app_group: app_group, role: role_owner)
        sign_in user
      end

      it 'does not update log_retention_days' do
        app.update(log_retention_days: 14)
        post :update_log_retention_days, params: { id: app.id, barito_app: { log_retention_days: 10 } }

        app.reload
        expect(app.log_retention_days).to eq(14)
      end
    end
  end
end
RSpec.describe 'Helm Infrastructures API', type: :request do
  # ...

  describe 'Delete Helm Infrastructure' do
    it 'should delete the Helm Infrastructure' do
      # Create a Helm Infrastructure
      helm_infrastructure = create(:helm_infrastructure, status: HelmInfrastructure.statuses[:active])

      # Send a DELETE request to the delete action
      delete api_v2_helm_infrastructure_delete_path(id: helm_infrastructure.cluster_name), headers: headers

      # Expect a successful response
      expect(response.status).to eq(200)

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Expect the response to indicate success
      expect(json_response['success']).to eq(true)
      expect(json_response['message']).to eq('Infrastructure deleted successfully')

      # Verify that the Helm Infrastructure has been deleted
      expect(HelmInfrastructure.find_by(cluster_name: helm_infrastructure.cluster_name)).to be_nil
    end

    it 'should return 404 if Helm Infrastructure is not found' do
      # Send a DELETE request to the delete action with an invalid ID
      delete api_v2_helm_infrastructure_delete_path(id: 'nonexistent_cluster'), headers: headers

      # Expect a 404 response
      expect(response.status).to eq(404)

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Expect the response to indicate failure and the reason
      expect(json_response['success']).to eq(false)
      expect(json_response['errors']).to eq(['Infrastructure not found'])
    end

    it 'should return 404 if Helm Infrastructure is not active' do
      # Create a Helm Infrastructure but set it to inactive
      helm_infrastructure = create(:helm_infrastructure, status: HelmInfrastructure.statuses[:inactive])

      # Send a DELETE request to the delete action
      delete api_v2_helm_infrastructure_delete_path(id: helm_infrastructure.cluster_name), headers: headers

      # Expect a 404 response
      expect(response.status).to eq(404)

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Expect the response to indicate failure and the reason
      expect(json_response['success']).to eq(false)
      expect(json_response['errors']).to eq(['Infrastructure not found'])
    end
  end
end
