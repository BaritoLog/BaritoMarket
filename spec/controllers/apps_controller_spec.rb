require 'rails_helper'

RSpec.describe AppsController, type: :controller do
  let(:infrastructure) { create(:infrastructure) }
  let(:app) { create(:barito_app, app_group: infrastructure.app_group) }

  let(:user) { create(:user) }

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
  end
end
