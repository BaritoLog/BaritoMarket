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

  def check_app_group
    valid, error_response = validate_required_keys(
      [:app_group_secret])
    render json: error_response, status: error_response[:code] and return unless valid

    app_group = AppGroup.find_by(secret_key: params[:app_group_secret])

    if app_group.blank? 
      render json: {
        success: false,
        errors: ["AppGroup is not found"],
        code: 404
      }, status: :not_found and return
    end

    render json: app_group.helm_infrastructure
  end

  def cluster_templates
   
    cluster_templates = HelmClusterTemplate.all.map do |cluster|
      cluster.slice(:id, :name)
    end
    
    if cluster_templates.blank?
      render json: {
        success: false,
        errors: ["Cluster templates are not found"],
        code: 404
      }, status: :not_found and return
    end

    render json: cluster_templates
  end

  private

  def app_group_params
    params.permit(:name, :cluster_template_id,)
  end

end
