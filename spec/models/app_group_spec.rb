require 'rails_helper'

RSpec.describe AppGroup, type: :model do
  context 'Setup Application' do
    let(:app_group_props) { build(:app_group) }

    it 'should create the app_group' do
      app_group, infrastructure = AppGroup.setup(
        Rails.env,
        name: app_group_props.name,
        capacity: 'small',
      )
      expect(app_group.persisted?).to eq(true)
    end
  end
end
