class Api::V3::AppGroupsController < Api::V3::BaseController
  include Wisper::Publisher

  def foo
    ag = AppGroup.find(1)
    authorize ag
    render json: {
      success: true,
      errors: nil,
      data: [
        current_user, session, ag,
      ],
    }, status: :ok
  end
end
