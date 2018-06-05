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
      expect(page.html.include?("<td class=\"app_list_name\"><a href=\"#{app_path(app)}\">#{app.name}</a></td>")).to eq(true)
      expect(page.html.include?("<td class=\"app_list_config text-center\">#{app.tps_config}</td>")).to eq(true)
      expect(page.html.include?("<td class=\"app_list_group text-center\">#{app.app_group}</td>")).to eq(true)
      expect(page.html.include?("<td class=\"app_list_status text-center\">#{status(app)}</td>")).to eq(true)
    end
  end
end
