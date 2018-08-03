group = Group.create(name: 'barito-superadmin')
user = User.create(email: 'superadmin@barito.com', username: 'superadmin', password: '123456', password_confirmation: '123456')
GroupUser.create(user: user, group: group)

['admin', 'owner', 'member'].each do |role|
  AppGroupRole.create(name: role)
end
