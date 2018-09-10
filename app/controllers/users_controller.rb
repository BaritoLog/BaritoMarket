class UsersController < ApplicationController
  def search
    @users = User.where("username ILIKE :q OR email ILIKE :q", { q: "%#{params[:q]}%" })
    render json: @users.map{ |u| { id: u.id, display_name: u.display_name }}
  end
end
