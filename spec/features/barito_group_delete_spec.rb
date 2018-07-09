require 'rails_helper'

RSpec.feature 'Delete Group', type: :feature do
  let(:user) { create(:user) }

  before(:each) do
    allow_any_instance_of(GateWrapper).to receive(:check_user_groups).and_return({groups: []})

    login_as user
  end

  scenario 'Delete 1 group' do
    create(:group)
    visit groups_path

    click_link 'Delete'

    expect(page).to have_content('No group registered')
  end
end
