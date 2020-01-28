require 'rails_helper'

RSpec.feature 'Barito App Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })
    @app_group = create(:app_group)
    cluster_template = create(:cluster_template)
    create(:infrastructure,
      app_group: @app_group,
      cluster_template_id: cluster_template.id,
      instances: cluster_template.instances,
      options: cluster_template.options,
    )
    @barito_app = create(:barito_app, app_group: @app_group, max_tps: 50)
    @barito_app2 = create(:barito_app, app_group:@app_group, max_tps: 50, topic_name: 'barito-app-2')
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

      scenario 'User can edit log retention days customization per app', js: true do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        create(:app_group_role)
        @barito_app.update(log_retention_days: 12345)
        login_as admin

        visit root_path
        click_link @app_group.name

        expect(page).to have_css("input#barito_app_#{@barito_app.id}_log_retention_days[value='#{@barito_app.log_retention_days}']")

        fill_in "barito_app_#{@barito_app.id}_log_retention_days", with: "20"
        find("input#barito_app_#{@barito_app.id}_log_retention_days").native.send_keys :enter

        wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
        alert = wait.until { page.driver.browser.switch_to.alert }
        alert.accept

        expect(page).to have_css("input#barito_app_#{@barito_app.id}_log_retention_days[value='20']")
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

      scenario 'User cannot edit barito app max tps if total all barito app max tps more than app_group capacity', js: true do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        create(:app_group_role)
        login_as admin

        visit root_path
        click_link @app_group.name

        expect(page).to have_css("input#barito_app_#{@barito_app.id}_max_tps[value='#{@barito_app.max_tps}']")

        new_value = @barito_app.max_tps + 20
        fill_in "barito_app_#{@barito_app.id}_max_tps", with: "#{new_value}"
        find("input#barito_app_#{@barito_app.id}_max_tps").native.send_keys :enter

        wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
        alert = wait.until { page.driver.browser.switch_to.alert }
        alert.accept

        expect(page).to have_content("With this new max TPS (#{new_value} TPS)")
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

      scenario 'User with "owner" or "admin" role can show custom log retention days in bold', js: true do
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role, :owner), user: user_b)
        @barito_app.update(log_retention_days: 12345)
        login_as user_b

        visit root_path
        click_link @app_group.name

        expect(page).not_to have_css("input#barito_app_#{@barito_app.id}_log_retention_days[value='#{@barito_app.log_retention_days}']")
        expect(page).to have_xpath("//b[text()='#{@barito_app.log_retention_days}']")
      end

      scenario 'User with "owner" or "admin" role can show non-custom log retention days per app', js: true do
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role, :owner), user: user_b)
        @app_group.update(log_retention_days: 23456)
        login_as user_b

        visit root_path
        click_link @app_group.name

        expect(page).to have_xpath("//td[text()='#{@app_group.log_retention_days}']")
      end
    end
  end
end
