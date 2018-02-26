class ServiceConfigsController < ApplicationController
  before_action :set_service_config, only: [:show, :edit, :update, :destroy]

  # GET /service_configs
  # GET /service_configs.json
  def index
    @service_configs = ServiceConfig.all
  end

  # GET /service_configs/1
  # GET /service_configs/1.json
  def show
  end

  # GET /service_configs/new
  def new
    @service_config = ServiceConfig.new
  end

  # GET /service_configs/1/edit
  def edit
  end

  # POST /service_configs
  # POST /service_configs.json
  def create
    @service_config = ServiceConfig.new(service_config_params)

    respond_to do |format|
      if @service_config.save
        format.html { redirect_to @service_config, notice: 'Service config was successfully created.' }
        format.json { render :show, status: :created, location: @service_config }
      else
        format.html { render :new }
        format.json { render json: @service_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_configs/1
  # PATCH/PUT /service_configs/1.json
  def update
    respond_to do |format|
      if @service_config.update(service_config_params)
        format.html { redirect_to @service_config, notice: 'Service config was successfully updated.' }
        format.json { render :show, status: :ok, location: @service_config }
      else
        format.html { render :edit }
        format.json { render json: @service_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_configs/1
  # DELETE /service_configs/1.json
  def destroy
    @service_config.destroy
    respond_to do |format|
      format.html { redirect_to service_configs_url, notice: 'Service config was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_config
      @service_config = ServiceConfig.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_config_params
      params.require(:service_config).permit(:ip_address, :config_json)
    end
end
