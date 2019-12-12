class GroupUsersController < ApplicationController
  def create
    @group_user = GroupUser.new(group_user_params)
    @group_user.role = AppGroupRole.find_by_name('member')
    @group_user.save

    redirect_to group_path(@group_user.group)
  end

  def destroy
    @group_user = GroupUser.find(params[:id])
    @group_user.destroy!
    redirect_to group_path(@group_user.group)
  end

  def set_role
    user = User.find(params[:user_id])
    group_user = user.group_users.find_by(group_id: params[:id])

    # Make sure only valid role that can be set to user
    role = AppGroupRole.find_by(id: params[:role_id])
    group_user.role = role || AppGroupRole.find_by_name('member')
    group_user.save

    redirect_to group_path(group_user.group_id)
  end

  private

  def group_user_params
    params.require(:group_user).permit(:group_id, :user_id)
  end
end
