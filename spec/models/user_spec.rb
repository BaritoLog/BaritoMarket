require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#self.find_by_username_or_email' do
    before(:each) do
      @user = create(:user, username: 'test_user', email: 'test@test.com')
    end

    it 'should return correctly if we find by username' do
      expect(User.find_by_username_or_email('test_user')).to eq @user
    end

    it 'should return correctly if we find by email' do
      expect(User.find_by_username_or_email('test@test.com')).to eq @user
    end
  end

  describe '#add_global_viewer_group' do
    let(:config) { YAML.load_file("#{Rails.root}/config/application.yml") }
    let(:group) { create(:group, name: 'global-viewer') }
    let(:user) { create(:user, username: 'test_user', email: 'test@test.com') }
      
    it "shoud add global viewer group to user if global viewer field in env is true" do 
      expect(user.groups.include?(group).to_s).to eq(config["GLOBAL_VIEWER"])
    end
  end
end
