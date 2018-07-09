class GroupUsersController < ApplicationController
  def create
    @group_user = GroupUser.new(group_user_params)
    @group_user.save

    redirect_to group_path(@group_user.group)
  end

  def destroy
    @group_user = GroupUser.find(params[:id])
    @group_user.destroy!
    pry
    redirect_to group_path(@group_user.group)
  end

  private

  def group_user_params
    params.require(:group_user).permit(:group_id, :user_id)
  end
end
