class AppGroupUsersController < ApplicationController
  def create
    app_group_user = AppGroupUser.new(app_group_user_params)
    app_group_user.role = AppGroupRole.as_member
    app_group_user.save

    redirect_to manage_access_app_group_path(app_group_user.app_group_id)
  end

  def set_role
    user = User.find(params[:user_id])

    # Delete existing roles first, excluding `member`
    AppGroupUser.
      where(
        'user_id = :user_id AND role_id != :role_id',
        user_id: user.id, role_id: AppGroupRole.as_member.id).
      delete_all


    app_group_user = AppGroupUser.new(app_group_user_params)
    app_group_user.user = user
    app_group_user.save

    # (app_group_user_params[:set_role] || []).each do |role|
    #   next unless roles.include?(role)

    #   app_group_user = AppGroupUser.create(
    #     app_group: app_group,
    #     user: user,
    #     role: AppGroupRole.find_by(name: role)
    #   )
    # end

    redirect_to manage_access_app_group_path(app_group_user.app_group_id)
  end

  def destroy
    user = User.find(params[:user_id])
    AppGroupUser.where(user: user).destroy_all

    redirect_to manage_access_app_group_path(params[:app_group_id])
  end

  private

  def app_group_user_params
    params.require(:app_group_user).permit(:app_group_id, :role_id, :user_id)
  end

  # def set_app_group_user
    # # @app_group_user = AppGroupUser.find(params[:id])
  # end
end
