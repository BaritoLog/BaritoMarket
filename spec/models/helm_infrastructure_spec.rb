require 'rails_helper'

RSpec.describe HelmInfrastructure, type: :model do
  subject { create(:helm_infrastructure) }

  it 'raises error if invalid override values' do
    subject.override_values = ""
    expect(subject.valid?).to eq false
  end

end
