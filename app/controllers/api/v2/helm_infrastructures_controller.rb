class Api::V2::HelmInfrastructuresController < Api::V2::BaseController
  def delete
    @helm_infrastructure = HelmInfrastructure.find_by(id: params[:id])
    
    if @helm_infrastructure.blank? || !@helm_infrastructure.active?
      render(json: {
                 success: false,
                 errors: ['Infrastructure not found'],
                 code: 404,
               }, status: :not_found) && return
    end
    
    @helm_infrastructure.delete
    render json: {
      success: true,
      message: 'Infrastructure deleted successfully',
    }
  end
end