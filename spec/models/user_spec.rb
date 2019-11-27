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
    let(:user) { create(:user, username: 'test_user', email: 'test@test.com') }

    it 'shoud add global viewer group to user if global viewer field in env is true' do
      expect(user.groups.any? do |g|
        g[:name] == Figaro.env.global_viewer_role
      end.to_s).to eq(config['GLOBAL_VIEWER'])
    end
  end

  describe '#can_access_app_group?' do
    let(:app_group) { create(:app_group) }
    let(:role) { create(:app_group_role) }
    let(:role_admin) { create(:app_group_role, :admin) }
    let(:user) { create(:user) }

    it 'should allow access to associated app group' do
      create(:app_group_user, app_group: app_group, user: user)
      expect(user.can_access_app_group?(app_group)).to be true
    end

    it 'should deny access to app group with no association' do
      expect(user.can_access_app_group?(app_group)).to be false
    end

    it 'should deny access to associated app group with different role' do
      create(:app_group_user, app_group: app_group, user: user, role: role)
      expect(user.can_access_app_group?(app_group, roles: [role_admin.name.to_s])).to be false
    end

    it 'should allow access to associated app group with any matched specified role' do
      create(:app_group_user, app_group: app_group, user: user, role: role)

      allowed_roles = [role_admin.name.to_s, role.name.to_s]
      expect(user.can_access_app_group?(app_group, roles: allowed_roles)).to be true
    end
  end
end
