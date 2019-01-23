class ExtAppsController < ApplicationController
  before_action :set_ext_app, only: %i(show edit update destroy)

  def index
    authorize ExtApp
    @ext_apps = ExtApp.all
  end

  def show
    authorize @ext_app
  end

  def new
    authorize ExtApp
    @ext_app = ExtApp.new
  end

  def edit
    authorize @ext_app
  end

  def create
    authorize ExtApp
    @ext_app = ExtApp.new(ext_app_params)
    access_token = SecureRandom.urlsafe_base64(48)
    @ext_app.access_token = access_token
    @ext_app.created_by_id = current_user.id

    if @ext_app.save
      flash[:access_token] = access_token
      redirect_to ext_app_path(@ext_app)
    else
      flash[:messages] = @ext_app.errors.full_messages
      render :new
    end
  end

  def update
    authorize @ext_app
    if @ext_app.update(ext_app_params)
      redirect_to @ext_app
    else
      flash[:messages] = @ext_app.errors.full_messages
      render :edit
    end
  end

  def destroy
    authorize @ext_app
    @ext_app.destroy
    redirect_to ext_apps_path
  end

  private
    def set_ext_app
      @ext_app = ExtApp.find(params[:id])
    end

    def ext_app_params
      params.require(:ext_app).permit(
        :name,
        :description,
      )
    end
end
