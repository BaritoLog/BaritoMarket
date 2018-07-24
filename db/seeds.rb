Group.create(name: 'barito-superadmin')

['admin', 'owner', 'member'].each do |role|
  AppGroupRole.create(name: role)
end
