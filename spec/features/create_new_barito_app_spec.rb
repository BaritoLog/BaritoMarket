require 'rails_helper'

RSpec.feature 'Create Application', type: :feature do
  scenario 'Success create new barito apps' do
    new_barito_app = build(:barito_app)
    before_count = BaritoApp.count

    visit new_app_path
    within('#new_barito_app') do
      fill_in 'barito_app_name', with: new_barito_app.name
      select new_barito_app.tps_config.capitalize, from: 'barito_app_tps_config'
      select new_barito_app.app_group, from: 'barito_app_app_group'
    end

    click_button 'Submit'

    expect(page).to have_current_path(root_path)
    expect(BaritoApp.count).not_to eq before_count
  end

  scenario 'Failed create new barito app' do
    invalid_barito_app = build(:barito_app, :invalid)
    invalid_barito_app.valid?

    visit new_app_path
    click_button 'Submit'

    expect(page).to have_current_path(new_app_path)
    expect(page).to have_content(invalid_barito_app.errors[:name].join(','))
  end
end
