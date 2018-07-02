class GroupsController < ApplicationController
  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to groups_path
    else
      flash[:messages] = @group.errors.full_messages
      render :new
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy!

    redirect_to groups_path
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end
end
