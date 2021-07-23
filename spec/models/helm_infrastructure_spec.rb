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
    context 'WHEN total count is 0' do
      it 'BY DEFAULT generates cluster index greater than seed' do
        expect(described_class.generate_cluster_index).to be > sequence_seed(0)
      end
    end

    context 'WHEN total count is not 0' do
      it 'generates next cluster index greater than seed' do
        total_count = 3
        Array.new(total_count) { create(:helm_infrastructure) }
        expect(described_class.generate_cluster_index).to be > sequence_seed(total_count)
      end
    end

    it 'generates NO overlapping cluster index to infrastructure causing duplicate cluster names' do
      total_count = 5
      infrastructure_clusters = Array.new(total_count) do
        create(:infrastructure)
        Rufus::Mnemo.from_integer(Infrastructure.generate_cluster_index)
      end.to_set
      helm_infrastructure_clusters = Array.new(total_count) do
        create(:helm_infrastructure)
        Rufus::Mnemo.from_integer(HelmInfrastructure.generate_cluster_index)
      end.to_set
      expect(infrastructure_clusters & helm_infrastructure_clusters).to be_empty
    end

    private

    def sequence_seed(total_count)
      1000 + 4 * (total_count + 1)
    end
  end
end
