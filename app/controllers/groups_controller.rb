class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :destroy]
  before_action only: [:show, :destroy] do
    authorize @group
  end

  def search
    @groups = Group.where('name ILIKE :q', { q: "%#{params[:q]}%" })
    render json: @groups
  end

  def index
    authorize Group
    @groups = Group.all
  end

  def show
    @group_user = GroupUser.new(group: @group)
    @group_users = GroupUser.includes(:user).where(group: @group)
  end

  def new
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
