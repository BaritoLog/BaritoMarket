class GroupsController < ApplicationController
  before_action :set_group, only: %i(show destroy)

  def index
    authorize Group
    @groups = Group.all
  end

  def search
    @groups = Group.where('name ILIKE :q', q: "%#{params[:q]}%")
    render json: @groups
  end

  def show
    authorize @group
    @group_user = GroupUser.new(group: @group)
    @group_users = GroupUser.includes(:user).where(group: @group)
  end

  def new
    authorize Group
    @group = Group.new
  end

  def create
    authorize Group
    @group = Group.new(group_params)

    if @group.save
      redirect_to groups_path
    else
      flash[:messages] = @group.errors.full_messages
      render :new
    end
  end

  def destroy
    authorize @group
    @group.destroy!
    redirect_to groups_path
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end

  def set_group
    @group = Group.find(params[:id])
  end
end
