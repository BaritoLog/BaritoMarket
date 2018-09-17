group = Group.create(name: 'barito-superadmin')

if Figaro.env.enable_cas_integration == 'true'
  user = User.create(email: 'superadmin@barito.com', username: 'superadmin')
else
  user = User.create(email: 'superadmin@barito.com', username: 'superadmin', password: '123456', password_confirmation: '123456')
end
GroupUser.create(user: user, group: group)

['admin', 'owner', 'member'].each do |role|
  AppGroupRole.create(name: role)
end
