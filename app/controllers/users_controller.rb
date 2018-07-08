class UsersController < ApplicationController
  def search
    @users = User.where("username ILIKE :q OR email ILIKE :q", { q: "%#{params[:q]}%" })
    render json: @users
  end

  def index
  end

  def show
    @user = current_user
  end
end
