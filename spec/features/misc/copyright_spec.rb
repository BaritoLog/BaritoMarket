require 'rails_helper'

RSpec.feature 'Miscellaneous', type: :feature do
  describe 'Copyright tag' do
    scenario 'At copyright year' do
      Timecop.freeze(2018, 1, 1) do
        visit root_path
        expect(page).to have_content('2018 Barito')
      end
    end

    scenario 'After copyright year' do
      Timecop.freeze(2019, 1, 1) do
        visit root_path
        expect(page).to have_content('2018-2019 Barito')
      end
    end
  end
end
