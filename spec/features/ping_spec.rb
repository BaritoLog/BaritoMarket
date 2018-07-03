require 'rails_helper'

RSpec.feature 'Ping Test Controller', type: :feature do
  before(:each) do
    user = create(:user)
    login_as(user)
  end

  scenario 'No apps are registered' do
    visit ping_path
    expect(page).to have_content('ok')
  end
end
