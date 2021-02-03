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

  shared_examples 'app group user-group associations' do |example_name|
    context 'user has member association with app group' do
      before :each do
        create(:app_group_user, app_group: app_group, user: user, role: role)
      end

      include_examples example_name
    end

    context 'user has member association with group associated to app group' do
      let(:group) { create(:group) }

      before :each do
        create(:app_group_team, app_group: app_group, group: group)
        create(:group_user, group: group, user: user, role: role)
      end

      include_examples example_name
    end
  end

  describe '#can_access_app_group?' do
    let(:app_group) { create(:app_group) }
    let(:user) { create(:user) }

    it 'should deny access to app group with no association' do
      expect(user.can_access_app_group?(app_group)).to be false
    end

    let(:role) { create(:app_group_role) }
    let(:role_admin) { create(:app_group_role, :admin) }

    shared_examples 'correct answerer' do
      it 'should allow access' do
        expect(user.can_access_app_group?(app_group)).to be true
      end

      it 'should deny access if not in specified roles' do
        allowed_roles = [role_admin.name.to_s]
        expect(user.can_access_app_group?(app_group, roles: allowed_roles)).to be false
      end

      it 'should allow access if in specified roles' do
        allowed_roles = [role_admin.name.to_s, role.name.to_s]
        expect(user.can_access_app_group?(app_group, roles: allowed_roles)).to be true
      end
    end

    include_examples 'app group user-group associations', 'correct answerer'
  end

  describe '#filter_accessible_app_groups' do
    let(:user) { create(:user) }
    let!(:app_group) { create(:app_group) }

    it 'should filter out unassociated app group' do
      app_groups = user.filter_accessible_app_groups(AppGroup.all)
      expect(app_groups.exists?).to be false
    end

    let(:role) { create(:app_group_role) }
    let(:role_admin) { create(:app_group_role, :admin) }

    shared_examples 'correct filter' do
      it 'should pass' do
        app_groups = user.filter_accessible_app_groups(AppGroup.all)
        expect(app_groups).to include(app_group)
      end

      it 'should filter out if not in specified roles' do
        allowed_roles = [role_admin.name.to_s]
        app_groups = user.filter_accessible_app_groups(AppGroup.all, roles: allowed_roles)
        expect(app_groups.exists?).to be false
      end

      it 'should pass if in specified roles' do
        allowed_roles = [role_admin.name.to_s, role.name.to_s]
        app_groups = user.filter_accessible_app_groups(AppGroup.all, roles: allowed_roles)
        expect(app_groups).to include(app_group)
      end
    end

    include_examples 'app group user-group associations', 'correct filter'
  end

  shared_examples 'group group-user user associations' do |example_name|
    context 'user has member association with group' do
      before :each do
        create(:group_user, group: group, user: user, role: role)
      end

      include_examples example_name
    end
  end

  describe '#can_access_user_group?' do
    let(:group) { create(:group) }
    let(:user) { create(:user) }

    it 'should deny access to app group with no association' do
      expect(user.can_access_user_group?(group)).to be false
    end

    let(:role) { create(:app_group_role) }
    let(:role_owner) { create(:app_group_role, :owner) }

    shared_examples 'correct answerer' do
      it 'should allow access' do
        expect(user.can_access_user_group?(group)).to be true
      end

      it 'should deny access if not in specified roles' do
        allowed_roles = [role_owner.name.to_s]
        expect(user.can_access_user_group?(group, roles: allowed_roles)).to be false
      end

      it 'should allow access if in specified roles' do
        allowed_roles = [role_owner.name.to_s, role.name.to_s]
        expect(user.can_access_user_group?(group, roles: allowed_roles)).to be true
      end
    end

    include_examples 'group group-user user associations', 'correct answerer'
  end

  describe '#filter_accessible_app_groups' do
    let(:user) { create(:user) }
    let!(:group) { create(:group) }

    it 'should filter out unassociated app group' do
      groups = user.filter_accessible_user_groups(Group.all)
      expect(groups.exists?).to be false
    end

    let(:role) { create(:app_group_role) }
    let(:role_owner) { create(:app_group_role, :owner) }

    shared_examples 'correct filter' do
      it 'should pass' do
        groups = user.filter_accessible_user_groups(Group.all)
        expect(groups).to include(group)
      end

      it 'should filter out if not in specified roles' do
        allowed_roles = [role_owner.name.to_s]
        groups = user.filter_accessible_user_groups(Group.all, roles: allowed_roles)
        expect(groups.exists?).to be false
      end

      it 'should pass if in specified roles' do
        allowed_roles = [role_owner.name.to_s, role.name.to_s]
        groups = user.filter_accessible_user_groups(Group.all, roles: allowed_roles)
        expect(groups).to include(group)
      end
    end

    include_examples 'group group-user user associations', 'correct filter'
  end
end
