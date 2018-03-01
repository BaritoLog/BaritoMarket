class Admin::BaseController < BaseController
  before_filter :authenticate_user

  def authenticate_user
    if EnabledFeatures.has?(:cas_integration)
      :authenticate_user!
    end
  end
end
