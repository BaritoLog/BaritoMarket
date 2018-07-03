require 'rails_helper'

RSpec.feature 'Show Application', type: :feature do
  before(:each) do
    user = create(:user)
    login_as(user)
  end

  scenario 'Show registered apps' do
    barito_app = create(:barito_app)

    visit root_path
    expect(page).to have_content(barito_app.name)

    click_link barito_app.name
    expect(page).to have_current_path(app_path(barito_app))
  end
end
