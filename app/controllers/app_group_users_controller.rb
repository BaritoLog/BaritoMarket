class AppGroupUsersController < ApplicationController
  def create
    app_group_user = AppGroupUser.new(app_group_user_params)
    app_group_user.role = AppGroupRole.find_by_name('member')
    app_group_user.save

    audit_log :app_group_add_user, { "user" => app_group_user.user.username }

    redirect_to manage_access_app_group_path(app_group_user.app_group_id)
  end

  def set_role
    user = User.find(params[:user_id])
    app_group_user = user.app_group_users.find_by(app_group_id: params[:app_group_id])
    from_role = app_group_user.role.name

    # Make sure only valid role that can be set to user
    role = AppGroupRole.find_by(id: params[:role_id])
    app_group_user.role = role || AppGroupRole.find_by_name('member')
    app_group_user.save

    audit_log :app_group_set_user_role, {
      "user" => app_group_user.user.username,
      "from_role" => from_role,
      "to_role" => app_group_user.role.name,
    }

    redirect_to manage_access_app_group_path(app_group_user.app_group_id)
  end

  def destroy
    user = User.find(params[:user_id])
    AppGroupUser.
      where(user: user, app_group_id: params[:app_group_id]).
      destroy_all

    audit_log :app_group_remove_user, { "user" => user.username }
    redirect_to manage_access_app_group_path(params[:app_group_id])
  end

  private

  def app_group_user_params
    params.require(:app_group_user).permit(:app_group_id, :role_id, :user_id)
  end
end
