require 'rails_helper'

RSpec.describe HelmInfrastructure, type: :model do
context 'relations' do
  it { is_expected.to belong_to(:app_group).required }
  it { is_expected.to belong_to(:helm_cluster_template).required }
  it { is_expected.to belong_to(:infrastructure_location).required }
end

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
  let(:default_infrastructure_location) { create(:infrastructure_location, name: Figaro.env.default_infrastructure_location) }

  it 'should create the helm_infrastructure' do
    helm_infrastructure = HelmInfrastructure.setup(
      app_group_id: app_group.id,
      helm_cluster_template_id: helm_cluster_template.id,
      infrastructure_location_id: default_infrastructure_location.id,
    )

    expect(helm_infrastructure).to be_persisted
  end
end

describe 'kibana & producer address' do
  let(:app_group) { create(:app_group) }
  let(:first_location) { create(:infrastructure_location,
    producer_address_format: 'first-%s-producer',
    kibana_address_format: 'first-%s-kibana') }
  let(:helm_infrastructure_with_location) { create(:helm_infrastructure, app_group: app_group, infrastructure_location: first_location) }

  context 'when attached to infrastructure_location' do
    it 'should return kibana_address based on location format address' do
      expect(helm_infrastructure_with_location.kibana_address).to(
        eq(sprintf(first_location.kibana_address_format, app_group.cluster_name))
      )
    end
    it 'should return producer_address based on location format address' do
      expect(helm_infrastructure_with_location.producer_address).to(
        eq(sprintf(first_location.producer_address_format, app_group.cluster_name))
      )
    end
  end

end

end
