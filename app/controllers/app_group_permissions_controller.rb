class AppGroupPermissionsController < ApplicationController
  def show
    @app_group = AppGroup.find(params[:id])
    @app_group_admin = AppGroupAdmin.new(app_group: @app_group)
    @app_group_admins = AppGroupAdmin.includes(:user).where(app_group: @app_group)
    @app_group_permission = AppGroupPermission.new(app_group: @app_group)
    @group_permissions = AppGroupPermission.includes(:group).where(app_group: @app_group)
  end

  def create
    @app_group_permission = AppGroupPermission.new(app_group_permission_params)

    unless @app_group_permission.save
      flash[:errors] = @app_group_permission.errors.full_messages
    end
    redirect_to app_group_permission_path(@app_group_permission.app_group)
  end

  def destroy
    @app_group_permission = AppGroupPermission.find(params[:id])
    @app_group_permission.destroy!

    redirect_to app_group_permission_path(@app_group_permission.app_group)
  end

  private

  def app_group_permission_params
    params.require(:app_group_permission).permit(:app_group_id, :group_id)
  end
end
