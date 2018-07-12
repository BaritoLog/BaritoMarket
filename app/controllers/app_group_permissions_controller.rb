class AppGroupPermissionsController < ApplicationController
  def create
    @app_group_permission = AppGroupPermission.new(app_group_permission_params)

    unless @app_group_permission.save
      flash[:errors] = @app_group_permission.errors.full_messages
    end
    redirect_to manage_access_app_group_path(@app_group_permission.app_group)
  end

  def destroy
    @app_group_permission = AppGroupPermission.find(params[:id])
    @app_group_permission.destroy!

    redirect_to manage_access_app_group_path(@app_group_permission.app_group)
  end

  private

  def app_group_permission_params
    params.require(:app_group_permission).permit(:app_group_id, :group_id)
  end
end
