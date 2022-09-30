class Api::V2::GroupUsersController < Api::V2::BaseController
  before_action :validate_params
  before_action :set_group
  before_action :set_user

  def create
    role = params[:group_role]
    app_group_role = AppGroupRole.find_by_name(role)
    render(json: { success: false, errors: ['App group role not found'], data: nil }, status: :not_found) && return if app_group_role.blank?

    group_user = GroupUser.create(group_id: @group.id, user_id: @user.id, role_id: app_group_role.id)
    render(json: { success: false, errors: [group_user.errors], data: nil }, status: :unprocessable_entity) && return unless group_user.valid?

    render json: { success: true, errors: nil, data: ['Group user created'] }, status: :ok
  end

  private

  def validate_params
    valid, error_response = validate_required_keys([:name, :group_role, :username])
    render json: error_response, status: error_response[:code] unless valid
  end

  def set_group
    @group = Group.find_by_name(params[:name])
    render json: { success: false, errors: ['Group not found'], data: nil }, status: :not_found if @group.blank?
  end

  def set_user
    @user = User.find_by_username_or_email(params[:username])
    render json: { success: false, errors: ['User not found'], data: nil }, status: :not_found if @user.blank?
  end
end
  