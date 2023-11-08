class GroupUsersController < ApplicationController
  def create
    set_group_from_input
    authorize @group_user

    @group_user = GroupUser.new(group_user_params)
    @group_user.role = AppGroupRole.find_by_name('member')
    @group_user.save

    audit_log :group_add_user, {
      "user" => @group_user.user.username,
      "group_name" => @group_user.group.name,
      "group_id" => @group_user.group.id,
    }

    redirect_to group_path(@group_user.group)
  end


  def destroy
    set_group_from_group_user
    authorize @group_user

    @group_user = GroupUser.find(params[:id])
    @group_user.destroy!

    audit_log :group_remove_user, {
      "user" => @group_user.user.username,
      "group_name" => @group_user.group.name,
      "group_id" => @group_user.group.id,
    }

    redirect_to group_path(@group_user.group)
  end

  def set_role
    set_group_from_params
    authorize @group_user

    user = User.find(params[:user_id])
    group_user = user.group_users.find_by(group_id: params[:id])
    previous_role = group_user.role.name

    # Make sure only valid role that can be set to user
    role = AppGroupRole.find_by(id: params[:role_id])
    group_user.role = role || AppGroupRole.find_by_name('member')
    group_user.save

    audit_log :group_role_changed, {
      "user" => user.username,
      "group_name" => group_user.group.name,
      "group_id" => group_user.group.id,
      "from_role" => previous_role ,
      "to_role" => group_user.role.name,
    }

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
