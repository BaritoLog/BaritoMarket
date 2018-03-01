class DatabagsController < ApplicationController
  before_action :set_databag, only: [:show, :edit, :update, :destroy]

  # GET /databags
  # GET /databags.json
  def index
    @databags = Databag.all
  end

  # GET /databags/1
  # GET /databags/1.json
  def show
  end

  # GET /databags/new
  def new
    @databag = Databag.new
  end

  # GET /databags/1/edit
  def edit
  end

  # POST /databags
  # POST /databags.json
  def create
    @databag = Databag.new(databag_params)

    respond_to do |format|
      if @databag.save
        format.html { redirect_to @databag, notice: 'Databag was successfully created.' }
        format.json { render :show, status: :created, location: @databag }
      else
        format.html { render :new }
        format.json { render json: @databag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /databags/1
  # PATCH/PUT /databags/1.json
  def update
    respond_to do |format|
      if @databag.update(databag_params)
        format.html { redirect_to @databag, notice: 'Databag was successfully updated.' }
        format.json { render :show, status: :ok, location: @databag }
      else
        format.html { render :edit }
        format.json { render json: @databag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /databags/1
  # DELETE /databags/1.json
  def destroy
    @databag.destroy
    respond_to do |format|
      format.html { redirect_to databags_url, notice: 'Databag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_databag
      @databag = Databag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def databag_params
      params.require(:databag).permit(:ip_address, :config_json, :tags)
    end
end
