class Api::V2::GroupsController < Api::V2::BaseController
  def create
    valid, error_response = validate_required_keys([:name])
    render json: error_response, status: error_response[:code] and return unless valid
    group = Group.find_by(name: params[:name])
    if group.blank?
      group = Group.create(name: params[:name])
    end
    render json: {
      data: group,
      code: 200,
      success: true
    }, status: :ok
  end

  def check_group
    valid, error_response = validate_required_keys([:name])
    render json: error_response, status: error_response[:code] and return unless valid
    group = Group.find_by(name: params[:name])
    if group.blank?
      render json: {
        success: false,
        errors: ["Group not found"],
        code: 404
      }, status: :not_found and return
    end
    render json: {
      data: group,
      code: 200,
      success: true
    }, status: :ok
  end
end
