class AppGroupAdminsController < ApplicationController
  def create
    @app_group_admin = AppGroupAdmin.new(app_group_admin_params)

    unless @app_group_admin.save
      flash[:errors] = @app_group_admin.errors.full_messages
    end

    redirect_to manage_access_app_group_path(@app_group_admin.app_group_id)
  end

  def destroy
    @app_group_admin = AppGroupAdmin.find(params[:id])
    @app_group_admin.destroy!

    redirect_to manage_access_app_group_path(@app_group_admin.app_group_id)
  end

  private

  def app_group_admin_params
    params.require(:app_group_admin).permit(:app_group_id, :user_id)
  end
end
