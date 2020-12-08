class Api::V2::AppGroupUsersController < Api::V2::BaseController
  include Wisper::Publisher

  around_action :wrap_span
  
  before_action :validate_params
  before_action :set_app_group
  before_action :set_user


  def wrap_span
    extracted_ctx = OpenTracing.extract(OpenTracing::FORMAT_RACK, request.headers)
    span_name = "barito_market.api.v2.#{params[:action]}"
    span = OpenTracing.start_span(span_name, child_of: extracted_ctx)

    OpenTracing.scope_manager.activate(span)
    scope = OpenTracing.scope_manager.active
    yield

    span.finish
  end

  def create
    app_group_role = AppGroupRole.find_by_name(params[:app_group_role])
    render(json: { success: false, errors: ['App group role not found'], data: nil }, status: :not_found) && return if app_group_role.blank?

    app_group_user = AppGroupUser.create(app_group_id: @app_group.id, user_id: @user.id, role_id: app_group_role.id)
    render(json: { success: false, errors: [app_group_user.errors], data: nil }, status: :unprocessable_entity) && return unless app_group_user.valid?

    render json: { success: true, errors: nil, data: ['App group user created'] }, status: :ok
  end

  private

  def validate_params
    valid, error_response = validate_required_keys([:app_group_secret, :app_group_role, :gate_username])
    render json: error_response, status: error_response[:code] unless valid
  end

  def set_app_group
    @app_group = AppGroup.find_by(secret_key: params[:app_group_secret])
    render json: { success: false, errors: ['App Group not found'], data: nil }, status: :not_found if @app_group.blank?
  end

  def set_user
    @user = User.find_by_username_or_email(params[:gate_username])
    render json: { success: false, errors: ['User not found'], data: nil }, status: :not_found if @user.blank?
  end
end
