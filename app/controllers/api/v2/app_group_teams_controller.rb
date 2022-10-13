class Api::V2::AppGroupTeamsController < Api::V2::BaseController
    before_action :validate_params
    before_action :set_app_group
    before_action :set_group
  
  def create
    app_group_team = AppGroupTeam.create(group_id: @group.id, app_group_id: @app_group.id)

    render(json: {
      success: false,
      errors: [app_group_team.errors],
      data: nil
      }, status: :unprocessable_entity
    ) && return unless app_group_team.valid?

    render json: {
      success: true, 
      errors: nil, 
      data: ["AppGroup team created successfully"]
      }, status: :ok
  end

  private

  def validate_params
    valid, error_response = validate_required_keys([:group_name, :app_group_name])
    render json: error_response, status: error_response[:code] unless valid
  end

  def set_group
    @group = Group.find_by(name: params[:group_name])
    render json: { success: false, errors: ['Group not found'], data: nil, code: 404 }, status: :not_found if @group.blank?
  end

  def set_app_group
    @app_group = AppGroup.find_by(name: params[:app_group_name])
    render json: { success: false, errors: ['AppGroup not found'], data: nil, code: 404 }, status: :not_found if @app_group.blank?
  end
end
    