require 'rails_helper'

RSpec.feature 'Application Group Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @app_group_a = create(:app_group)

    [@app_group_a].each { |app_group| create(:infrastructure, app_group: app_group, provisioning_status: 'FINISHED') }
  end

  describe 'Delete Infrastructure' do
    context 'As Superadmin' do
      scenario 'User can delete Infrastructure', js: true do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        create(:app_group_role)
        login_as admin
        visit app_group_path(@app_group_a)
        expect(@app_group_a.infrastructure.status).to eq Infrastructure.statuses[:inactive]

        expect(page).to have_content(@app_group_a.infrastructure.cluster_name)
        expect(page).to have_css("#delete_infrastructure_#{@app_group_a.infrastructure.id}")
        expect(page).to have_selector(:css, "a[href='/app_groups/#{@app_group_a.id}/delete_infrastructure/#{@app_group_a.infrastructure.id}']")

        accept_alert do
          click_link 'Delete Infrastructure'
        end
        @app_group_a.infrastructure.reload
        expect(page).to have_content("DELETE_STARTED")
      end
    end

    context 'As Authorized Use based on Role' do
      scenario 'User with role other than "superadmin" are not allowed to delete infrastructure', js: true do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :admin), user: user_b)

        login_as user_b
        visit app_group_path(@app_group_a)
        expect(@app_group_a.infrastructure.status).to eq Infrastructure.statuses[:inactive]

        expect(page).to have_content(@app_group_a.infrastructure.cluster_name)

        expect(page).not_to have_css("#delete_infrastructure_#{@app_group_a.infrastructure.id}")
        expect(page).not_to have_selector(:css, "a[href='/app_groups/#{@app_group_a.id}/delete_infrastructure/#{@app_group_a.infrastructure.id}']")
      end
    end
  end
end
