require 'rails_helper'

RSpec.describe HelmInfrastructure, type: :model do
  context 'validates' do
    describe ':override_values' do
      context 'Nil (default value) is a valid Override Values' do
        subject { build(:helm_infrastructure, override_values: nil) }

        it { is_expected.to validate_helm_values_of(:override_values) }
      end

      context 'Hash is a valid Override Values' do
        subject { build(:helm_infrastructure, override_values: {}) }

        it { is_expected.to validate_helm_values_of(:override_values) }
      end

      context 'String is an invalid Override Values' do
        subject { build(:helm_infrastructure, override_values: '') }

        it { is_expected.to_not validate_helm_values_of(:override_values) }
      end
    end
  end

  describe '.setup' do
    let(:app_group) { create(:app_group) }
    let(:helm_cluster_template) { create(:helm_cluster_template) }

    it 'should create the helm_infrastructure' do
      helm_infrastructure = HelmInfrastructure.setup(
        app_group_id: app_group.id,
        helm_cluster_template_id: helm_cluster_template.id,
        )

      expect(helm_infrastructure).to be_persisted
    end
  end

  describe '.generate_cluster_index' do
    it 'by default generates cluster index equal to cluster padding' do
      expect(described_class.generate_cluster_index).to eq(described_class::CLUSTER_NAME_PADDING)
    end

    it 'generates cluster index based on count' do
      infrastructures = Array.new(3) { create(:helm_infrastructure) }
      cluster_index = described_class::CLUSTER_NAME_PADDING + infrastructures.count
      expect(described_class.generate_cluster_index).to eq(cluster_index)
    end
  end
end
