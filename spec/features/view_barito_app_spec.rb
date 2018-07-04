require 'rails_helper'

RSpec.feature 'View Applications', type: :feature do
  before(:each) do
    user = create(:user)
    login_as(user)
  end

  scenario 'View registered applications' do
    infrastructure = create(:infrastructure)
    app_group = infrastructure.app_group
    barito_app = create(:barito_app, app_group: app_group)

    visit root_path
    expect(page).to have_content(app_group.name)

    click_link app_group.name
    expect(page).to have_current_path(app_group_path(app_group))
    expect(page).to have_content(barito_app.name).and have_content(barito_app.topic_name)
  end
end
