require 'rails_helper'

RSpec.feature 'New Application', type: :feature do
  scenario 'Prepare create new app' do
    new_barito_app = build(:barito_app)
    visit new_app_path
    expect(page).to have_content('TPS Configuration')
    expect(page).to have_content('Application Group')

    within('#new_barito_app') do
      fill_in 'barito_app_name', with: new_barito_app.name
      select new_barito_app.tps_config.capitalize, from: 'barito_app_tps_config'
      select new_barito_app.app_group, from: 'barito_app_app_group'
    end

    expect(page.find_field('barito_app_name').value).to eq new_barito_app.name
    expect(page.find_field('barito_app_tps_config').value).to eq new_barito_app.tps_config.capitalize
    expect(page.find_field('barito_app_app_group').value).to eq new_barito_app.app_group
  end
end
