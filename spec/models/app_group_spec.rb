require 'rails_helper'

RSpec.describe AppGroup, type: :model do
  context 'uniqueness validation' do
    describe ':name' do
      subject { create(:app_group) }

      it { is_expected.to validate_uniqueness_of(:name) }
    end
  end

  context 'presence validation' do
    it 'should check presence of name' do
      expect(build(:app_group, name: nil)).not_to be_valid
    end

    it 'should check presence of secret_key' do
      expect(build(:app_group, secret_key: nil)).not_to be_valid
    end
  end

  context 'Setup Application' do
    let(:app_group_props) { build(:app_group) }
    let(:helm_cluster_template) { create(:helm_cluster_template) }

    it 'should create the app_group and helm_infra' do
      app_group, helm_infrastructure = AppGroup.setup(
        name: app_group_props.name,
        secret_key: AppGroup.generate_key,
        capacity: 'small',
        cluster_template_id: helm_cluster_template.id,
      )

      expect(app_group.persisted?).to eq(true)
      expect(helm_infrastructure.persisted?).to eq(true)
    end

    it 'should able to change environment to staging' do
      app_group, = AppGroup.setup(
        name: app_group_props.name,
        capacity: 'small',
        cluster_template_id: helm_cluster_template.id,
        environment: 'staging',
      )

      expect(app_group.staging?).to be true
    end
  end
end
