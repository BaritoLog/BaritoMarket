superadmin_group = Group.create(name: 'barito-superadmin')
global_viewer_group = Group.create(name: Figaro.env.global_viewer_role)

if Figaro.env.enable_cas_integration == 'true'
  user = User.create(email: 'superadmin@barito.com', username: 'superadmin')
else
  user = User.create(email: 'superadmin@barito.com', username: 'superadmin', password: '123456', password_confirmation: '123456')
end
GroupUser.create(user: user, group: superadmin_group)
GroupUser.create(user: user, group: global_viewer_group)

['admin', 'owner', 'member'].each do |role|
  AppGroupRole.create(name: role)
end

load "#{::Rails.root}/db/seeds/master_data/cluster_template.rb"
load "#{::Rails.root}/db/seeds/master_data/component_property.rb"