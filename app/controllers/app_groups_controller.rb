class AppGroupsController < ApplicationController
  before_action :set_app_group, only: [:show, :edit, :update, :destroy]

  # GET /app_groups
  # GET /app_groups.json
  def index
    @app_groups = AppGroup.all
  end

  # GET /app_groups/1
  # GET /app_groups/1.json
  def show
  end

  # GET /app_groups/new
  def new
    @app_group = AppGroup.new
  end

  # GET /app_groups/1/edit
  def edit
  end

  # POST /app_groups
  # POST /app_groups.json
  def create
    @app_group = AppGroup.new(app_group_params)

    respond_to do |format|
      if @app_group.save
        format.html { redirect_to @app_group, notice: 'App group was successfully created.' }
        format.json { render :show, status: :created, location: @app_group }
      else
        format.html { render :new }
        format.json { render json: @app_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /app_groups/1
  # PATCH/PUT /app_groups/1.json
  def update
    respond_to do |format|
      if @app_group.update(app_group_params)
        format.html { redirect_to @app_group, notice: 'App group was successfully updated.' }
        format.json { render :show, status: :ok, location: @app_group }
      else
        format.html { render :edit }
        format.json { render json: @app_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /app_groups/1
  # DELETE /app_groups/1.json
  def destroy
    @app_group.destroy
    respond_to do |format|
      format.html { redirect_to app_groups_url, notice: 'App group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_group
      @app_group = AppGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def app_group_params
      params.require(:app_group).permit(:name)
    end
end
