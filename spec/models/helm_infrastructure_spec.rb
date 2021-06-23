require 'rails_helper'

RSpec.describe HelmInfrastructure, type: :model do
  subject { create(:helm_infrastructure) }
  let(:app_group) { create(:app_group) }
  let(:helm_cluster_template) { create(:helm_cluster_template) }

  it 'raises error if invalid override values' do
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

end
