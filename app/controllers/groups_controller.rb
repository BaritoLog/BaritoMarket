class GroupsController < ApplicationController
  before_action :set_group, only: %i(show destroy)

  def index
    authorize Group
    @allow_create_new_group = policy(Group).create?
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

    @allow_manage_group_access = policy(@group).manage_access?
    @roles = {
      member: AppGroupRole.find_by_name('member'),
      admin: AppGroupRole.find_by_name('admin'),
      owner: AppGroupRole.find_by_name('owner'),
    }
  end

  def new
    authorize Group
    @group = Group.new
  end

  def create
    authorize Group
    @group = Group.new(group_params)

    if @group.save
      audit_log :create_new_group, { "group_id" => @group.id, "group_name" => @group.name }
      redirect_to groups_path
    else
      flash[:messages] = @group.errors.full_messages
      render :new
    end
  end

  def destroy
    authorize @group
    @group.destroy!

    audit_log :delete_group, { "group_id" => @group.id, "group_name" => @group.name }
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
