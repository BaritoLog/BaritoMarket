require 'rails_helper'

RSpec.feature 'Barito App Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })
    @app_group = create(:app_group)
    cluster_template = create(:cluster_template)
    create(:infrastructure, app_group: @app_group, cluster_template_id: cluster_template.id)
    @barito_app = create(:barito_app, app_group: @app_group)
  end

  describe 'Edit max tps' do
    context 'As Superadmin' do
      scenario 'User can edit barito app max tps', js: true do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        create(:app_group_role)
        login_as admin

        visit root_path
        click_link @app_group.name

        expect(page).to have_css("input#barito_app_#{@barito_app.id}_max_tps[value='#{@barito_app.max_tps}']")

        fill_in "barito_app_#{@barito_app.id}_max_tps", with: "20"
        find("input#barito_app_#{@barito_app.id}_max_tps").native.send_keys :enter

        wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
        alert = wait.until { page.driver.browser.switch_to.alert }
        alert.accept

        expect(page).to have_css("input#barito_app_#{@barito_app.id}_max_tps[value='20']")
      end

      scenario 'User cannot edit barito app max tps if more than app_group capacity', js: true do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        create(:app_group_role)
        login_as admin

        visit root_path
        click_link @app_group.name

        expect(page).to have_css("input#barito_app_#{@barito_app.id}_max_tps[value='#{@barito_app.max_tps}']")

        new_value = @app_group.max_tps + 20
        fill_in "barito_app_#{@barito_app.id}_max_tps", with: "#{new_value}"
        find("input#barito_app_#{@barito_app.id}_max_tps").native.send_keys :enter

        wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
        alert = wait.until { page.driver.browser.switch_to.alert }
        alert.accept

        expect(page).to have_content("Max TPS (#{new_value} TPS) should be less than AppGroup capacity (#{@app_group.max_tps} TPS)")
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with "owner" or "admin" role can edit max tps barito app', js: true do
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role, :owner), user: user_b)

        login_as user_b

        visit root_path
        click_link @app_group.name

        expect(page).to have_css("input#barito_app_#{@barito_app.id}_max_tps[value='#{@barito_app.max_tps}']")

        fill_in "barito_app_#{@barito_app.id}_max_tps", with: "20"
        find("input#barito_app_#{@barito_app.id}_max_tps").native.send_keys :enter

        wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
        alert = wait.until { page.driver.browser.switch_to.alert }
        alert.accept

        expect(page).to have_css("input#barito_app_#{@barito_app.id}_max_tps[value='20']")
      end

      scenario 'User with "member" role cannot edit barito app', js: true do
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role), user: user_b)

        login_as user_b

        visit root_path
        click_link @app_group.name

        expect(page).not_to have_css("input#barito_app_#{@barito_app.id}_max_tps")
      end
    end
  end
end
