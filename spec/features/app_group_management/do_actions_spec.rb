require 'rails_helper'

RSpec.feature 'Application Group Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @app_group_a = create(:app_group, created_by: user_a)
    @app_group_b = create(:app_group, created_by: user_b)

    [@app_group_a, @app_group_b].each { |app_group| create(:infrastructure, app_group: app_group) }
  end

  describe 'Do Updrade/Manage Access and Create/Delete Barito App' do
    context 'As Owner' do
      scenario 'User can do those actions' do
        login_as user_a

        visit root_path
        click_link @app_group_a.name

        expect(page).to have_content('Create')
        expect(page).to have_content('Manage Access')
        expect(page).to have_content('Upgrade')
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with role member cannot do any actions' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role), user: user_b)

        login_as user_b
        visit root_path

        click_link @app_group_a.name

        expect(page).to have_current_path(app_group_path(@app_group_a))
        expect(page).not_to have_css('input[name="commit"][value="Create"]')
        expect(page).not_to have_content('Manage Access')
        expect(page).not_to have_content('Upgrade')
      end
    end
  end
end
