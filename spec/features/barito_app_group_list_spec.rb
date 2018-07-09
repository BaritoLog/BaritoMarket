require 'rails_helper'

RSpec.feature 'List Application Groups', type: :feature do
  let(:user) { create(:user) }

  before(:each) do
    allow_any_instance_of(GateWrapper).to receive(:check_user_groups).and_return({groups: []})

    login_as user
  end

  scenario 'No app groups are registered' do
    visit root_path
    expect(page).to have_content('Looks like you have no access to any application groups right now')
  end

  scenario 'App groups are registered' do
    app_groups = create_list(:app_group, 5, created_by: user)
    app_groups.each{ |x| create(:infrastructure, app_group: x) }
    visit root_path
    app_groups.each do |app_group|
      [
        { class_list: %w[text-center], content: "<a href=\"#{app_group_path(app_group)}\">#{app_group.name}</a>" },
        { class_list: %w[text-center], content: app_group.infrastructure.capacity },
        { class_list: %w[text-center], content: app_group.infrastructure.provisioning_status },
        { class_list: %w[text-center], content: app_group.infrastructure.status },
      ].each do |cell|
        content = AppViewHelper.generate_list_cell_content(cell[:class_list], cell[:content])
        expect(page.html.include?(content)).to eq(true)
      end
    end
  end
end
