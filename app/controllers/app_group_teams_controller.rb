class AppGroupTeamsController < ApplicationController
  def create
    app_group_team = AppGroupTeam.new(app_group_team_params)
    app_group_team.role = AppGroupRole.find_by_name('member')
    app_group_team.save
    redirect_to manage_access_app_group_path(app_group_team.app_group_id)
  end

  def destroy
    group = Group.find(params[:group_id])
    AppGroupTeam.
      where(group: group, app_group_id: params[:app_group_id]).
      destroy_all
    redirect_to manage_access_app_group_path(params[:app_group_id])
  end

  private

  def app_group_team_params
    params.require(:app_group_team).permit(:app_group_id, :role_id, :group_id)
  end
end
