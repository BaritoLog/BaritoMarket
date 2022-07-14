superadmin_group = Group.create(name: 'barito-superadmin')
global_viewer_group = Group.create(name: Figaro.env.global_viewer_role)

['admin', 'owner', 'member'].each do |role|
  AppGroupRole.create(name: role)
end

if Figaro.env.enable_sso_integration == 'false'
  user = User.create(email: 'superadmin@barito.com', username: 'superadmin', password: '123456', password_confirmation: '123456')
end
GroupUser.create(user: user, group: superadmin_group, role: AppGroupRole.find_by_name('admin'))
GroupUser.create(user: user, group: global_viewer_group, role: AppGroupRole.find_by_name('admin'))



load "#{::Rails.root}/db/seeds/master_data/cluster_template.rb"
load "#{::Rails.root}/db/seeds/master_data/deployment_template.rb"
load "#{::Rails.root}/db/seeds/master_data/helm_cluster_template.rb"
