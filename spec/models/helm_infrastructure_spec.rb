require 'rails_helper'

RSpec.describe HelmInfrastructure, type: :model do
  subject { create(:helm_infrastructure) }

  let(:app_group) { create(:app_group) }
  let(:helm_cluster_template) { create(:helm_cluster_template) }

  it 'raises error if invalid override values' do
    # noinspection RubyResolve
    subject.override_values = ""
    expect(subject.valid?).to eq false
  end

  it 'should create the helm_infrastructure' do
    helm_infrastructure = HelmInfrastructure.setup(
      app_group_id: app_group.id,
      helm_cluster_template_id: helm_cluster_template.id,
    )

    expect(helm_infrastructure.persisted?).to eq(true)
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
