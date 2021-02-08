class GroupUsersController < ApplicationController
  def create
    set_group_from_input
    authorize @group_user

    @group_user = GroupUser.new(group_user_params)
    @group_user.role = AppGroupRole.find_by_name('member')
    @group_user.save

    redirect_to group_path(@group_user.group)
  end


  def destroy
    set_group_from_group_user
    authorize @group_user

    @group_user = GroupUser.find(params[:id])
    @group_user.destroy!
    redirect_to group_path(@group_user.group)
  end

  def set_role
    set_group_from_params
    authorize @group_user

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

  def set_group_from_input
    @group_user = GroupUser.find_by(group_id: group_user_params[:group_id], user_id: current_user.id) || GroupUser.new()
  end

  def set_group_from_params
    @group_user = GroupUser.find_by(group_id: params[:id], user_id: current_user.id) || GroupUser.new()
  end

  def set_group_from_group_user
    @group_user = GroupUser.find_by(group_id: GroupUser.find(params[:id]).group_id, user_id: current_user.id) || GroupUser.new()
  end
end
