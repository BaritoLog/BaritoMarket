class AppsController < ApplicationController
  before_action :set_config
  before_action :set_app, only: [:show, :edit, :update, :destroy, :infra_setup, :infra_configuration]

  # GET /apps
  # GET /apps.json
  def index
    @apps = App.all
  end

  # GET /apps/1
  # GET /apps/1.json
  def show
  end

  # GET /apps/new
  def new
    @app = App.new
  end

  # GET /apps/1/edit
  def edit
  end

  # POST /apps
  # POST /apps.json
  def create
    @app = App.new(app_params)

    respond_to do |format|
      if @app.save
        blueprint = Blueprint.new(@app, @tps_config, @chef_configs)
        blueprint.to_file
        @app.set_cluster_name(blueprint.cluster_name)
        format.html { redirect_to controller: 'apps', action: 'infra_setup', id: @app.id , notice: 'App was successfully created.' }
        format.json { render :show, status: :created, location: @app }
      else
        format.html { render :new }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /apps/1
  # PATCH/PUT /apps/1.json
  def update
    respond_to do |format|
      if @app.update(app_params)
        format.html { redirect_to @app, notice: 'App was successfully updated.' }
        format.json { render :show, status: :ok, location: @app }
      else
        format.html { render :edit }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apps/1
  # DELETE /apps/1.json
  def destroy
    @app.destroy
    respond_to do |format|
      format.html { redirect_to apps_url, notice: 'App was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  # GET /setup/1
  def infra_setup
  end
  
  # GET /configuration/1
  def infra_configuration
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app
      @app = App.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def app_params
      params.require(:app).permit(:name, :tps_config_id, :app_group_id)
    end

    def set_config
      @tps_config = TpsConfig.new(TPS_CONFIG)
      @chef_configs = ChefConfigs.new(CHEF_CONFIG)
    end
end
