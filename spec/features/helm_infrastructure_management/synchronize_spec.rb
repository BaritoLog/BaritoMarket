require 'rails_helper'

RSpec.feature 'Helm Infrastructure Management', type: :feature do
  let(:user_a) { create(:user) }
  before(:each) do
    infrastructure = create(:infrastructure)
    @helm_infrastructure = create(
      :helm_infrastructure,
      app_group: infrastructure.app_group
    )
  end

  describe 'Helm Infrastructure' do
    context 'Synchronize Helm Infrastructure' do
      scenario 'User can synchronize Helm Infrastructure' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a

        visit helm_infrastructure_path(@helm_infrastructure)

        expect {
          click_link('Synchronize')
        }.to change(HelmSyncWorker.jobs, :size).by(1)
      end
    end
  end
end
