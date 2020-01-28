require 'rails_helper'

RSpec.describe AppsController, type: :controller do
  let(:infrastructure) { create(:infrastructure) }
  let(:app_group) { infrastructure.app_group }
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
