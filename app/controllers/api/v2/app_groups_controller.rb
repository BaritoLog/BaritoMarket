class Api::V2::AppGroupsController < Api::V2::BaseController
  include Wisper::Publisher

  def create_app_group
    errors = []

    if not app_group_params.blank?
      @app_group, @infrastructure = AppGroup.setup(app_group_params)
      if @app_group.blank?
        errors << "No new app group was created"
      end
    end

    if errors.empty? && !app_group_params.blank?
      render json: {
        data: @app_group
      }, status: :ok
    else
      render json: {
        success: false,
        errors: errors,
        code: 404
      }, status: :not_found
    end
  end

  private

  def app_group_params
    params.permit(:name, :cluster_template_id,)
  end

end
