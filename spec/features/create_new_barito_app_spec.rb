require 'rails_helper'

RSpec.feature 'Create Application', type: :feature do
  before(:each) do
    user = create(:user)
    login_as user
  end

  scenario 'Success create new barito apps' do
    app_group = build(:app_group)
    before_count = AppGroup.count

    visit new_app_group_path
    within('#app_group_form') do
      fill_in 'app_group[name]', with: app_group.name
      select TPS_CONFIG.keys[0], from: 'app_group[capacity]'
    end

    click_button 'Submit'

    expect(page).to have_current_path(root_path)
    expect(AppGroup.count).not_to eq before_count

    click_link app_group.name
    barito_app = build(:barito_app)
    before_count = BaritoApp.count

    within('#new_barito_app') do
      fill_in 'barito_app[name]', with: barito_app.name
      fill_in 'barito_app[topic_name]', with: barito_app.topic_name
    end

    click_button 'Create'

    expect(page).to have_content(barito_app.name).and have_content(barito_app.topic_name)
    expect(BaritoApp.count).not_to eq before_count
  end
end
