class Admin::BaseController < BaseController
  before_filter :authenticate_user!
end
