require 'rails_helper'

RSpec.feature "Application Group Management", type: :feature do
  let(:user) { create(:user) }
  let(:user_b) { create(:user) }
  let(:helm_cluster_template) { create(:helm_cluster_template) }

  before(:each) do
    @app_group = create(:helm_infrastructure, helm_cluster_template: helm_cluster_template).app_group
    set_check_user_groups({ 'groups': ['barito-superadmin'] })

    login_as user
  end

  scenario "It has no Show Helm Infrastructure button" do
    set_check_user_groups('groups' => [])
    create(
      :app_group_user, app_group: @app_group, role: create(:app_group_role, :admin),
       user: user
    )

    visit root_path
    click_link @app_group.name

    expect(page).not_to have_content("Show Helm Infrastructure")
  end

  context "With Helm Infrastructure" do
    before(:each) do
      create(:helm_infrastructure, app_group: @app_group, helm_cluster_template: helm_cluster_template)
    end

    scenario "It has Show Helm Infrastructure button" do
      visit root_path
      click_link @app_group.name

      expect(page).to have_content("Show Helm Infrastructure")
    end
  end
end
