require 'rails_helper'

RSpec.describe Group, type: :model do
  it 'name should not empty' do
    expect(create(:group).name).not_to be_nil
  end
end
