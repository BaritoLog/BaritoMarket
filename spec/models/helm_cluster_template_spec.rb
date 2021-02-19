require 'rails_helper'

RSpec.describe HelmClusterTemplate, type: :model do
  subject { create(:helm_cluster_template) }

  it { is_expected.to validate_presence_of(:max_tps) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }

  it 'raises error if invalid values yaml' do
    subject.values = ""
    expect(subject.valid?).to eq false
  end
end
