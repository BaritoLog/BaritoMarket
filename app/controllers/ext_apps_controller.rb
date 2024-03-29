class ExtAppsController < ApplicationController
  before_action :set_ext_app, only: %i(show edit update destroy regenerate_token)

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


    audit_log :create_new_ext_app, { "ext_app_id" => @ext_app.id, "ext_app_name" => @ext_app.name }

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
      audit_log :update_ext_app, { "ext_app_id" => @ext_app.id, "ext_app_name" => @ext_app.name }
      redirect_to @ext_app
    else
      flash[:messages] = @ext_app.errors.full_messages
      render :edit
    end
  end

  def destroy
    authorize @ext_app
    @ext_app.destroy

    audit_log :delete_ext_app, { "ext_app_id" => @ext_app.id, "ext_app_name" => @ext_app.name }

    redirect_to ext_apps_path
  end

  def regenerate_token
    authorize @ext_app
    access_token = SecureRandom.urlsafe_base64(48)
    if @ext_app.update(access_token: access_token)
      audit_log :regenerate_token_ext_app, { "ext_app_id" => @ext_app.id, "ext_app_name" => @ext_app.name }
      flash[:access_token] = access_token
      redirect_to @ext_app
    else
      redirect_to @ext_app
    end
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
