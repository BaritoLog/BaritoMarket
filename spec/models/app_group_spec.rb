require 'rails_helper'

RSpec.describe AppGroup, type: :model do
  context 'Setup Application' do
    let(:app_group_props) { build(:app_group) }
    let(:cluster_template) { create(:cluster_template) }

    it 'should create the app_group' do
      app_group, = AppGroup.setup(
        name: app_group_props.name,
        secret_key: AppGroup.generate_key,
        capacity: 'small',
        cluster_template_id: cluster_template.id,
      )
      expect(app_group.persisted?).to eq(true)
    end
  end
end
