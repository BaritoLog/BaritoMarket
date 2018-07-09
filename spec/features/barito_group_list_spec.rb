require 'rails_helper'

RSpec.feature 'List Groups', type: :feature do
  let(:user) { create(:user) }

  before(:each) do
    allow_any_instance_of(GateWrapper).to receive(:check_user_groups).and_return({groups: []})

    login_as user
  end

  scenario 'No groups are registered' do
    visit groups_path
    expect(page).to have_content('No group registered')
  end

  scenario 'Groups are registered' do
    groups = create_list(:group, 5)
    visit groups_path
    groups.each do |group|
      expect(page).to have_content(group.name)
    end
  end
end
