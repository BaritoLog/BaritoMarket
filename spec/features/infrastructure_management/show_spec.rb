require 'rails_helper'

RSpec.feature 'Infrastructure Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) do
    @infrastructure = create(:infrastructure)
    @infrastructure_components = []
    3.times.each do
      @infrastructure_components << create(:infrastructure_component, infrastructure: @infrastructure)
    end
  end

  describe 'View infrastructure details' do
    context 'As Owner/Superadmin' do
      it 'shows' do
        login_as user

        visit infrastructure_path(@infrastructure.id)
        expect(page).to have_content(@infrastructure.name)
        @infrastructure_components.each do |component|
          expect(page).to have_content(component.hostname)
        end
      end
    end
  end
end
