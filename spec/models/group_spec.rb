require 'rails_helper'

RSpec.describe Group, type: :model do
  it 'should set gid' do
    expect(create(:group).gid).not_to be_nil
  end
end
