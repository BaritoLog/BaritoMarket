desc 'Temporary rake task to convert multiple role to single role user'
task :fix_user_role, :environment do |t|
  User.all.each do |user|
    app_group_users = AppGroupUser.where(user_id: user.id)

    if app_group_users.count > 1
      app_group_users.last.destroy
    end
  end
end
