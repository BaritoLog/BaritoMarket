require 'rails_helper'
RSpec.feature 'List Applications', type: :feature do

  scenario 'No apps are registered' do
    visit root_path
    expect(page).to have_content('Looks like you have no access to any applications right now')
  end

  scenario 'Apps are registered' do
    apps = create_list(:barito_app, 5)
    visit root_path
    apps.each do |app|
      [
        { class_list: %w[app_list_name], content: "<a href=\"#{app_path(app)}\">#{app.name}</a>" },
        { class_list: %w[app_list_config text-center], content: app.tps_config },
        { class_list: %w[app_list_group text-center], content: app.app_group },
        { class_list: %w[app_list_status text-center], content: status(app) },
      ].each do |cell|
        content = AppViewHelper.generate_list_cell_content(cell[:class_list], cell[:content])
        expect(page.html.include?(content)).to eq(true)
      end
    end
  end
end
