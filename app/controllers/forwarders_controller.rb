class ForwardersController < ApplicationController
  before_action :set_forwarder, only: [:show, :edit, :update, :destroy]

  # GET /forwarders
  # GET /forwarders.json
  def index
    @forwarders = Forwarder.all
  end

  # GET /forwarders/1
  # GET /forwarders/1.json
  def show
  end

  # GET /forwarders/new
  def new
    @forwarder = Forwarder.new
  end

  # GET /forwarders/1/edit
  def edit
  end

  # POST /forwarders
  # POST /forwarders.json
  def create
    @forwarder = Forwarder.new(forwarder_params)

    respond_to do |format|
      if @forwarder.save
        format.html { redirect_to @forwarder, notice: 'Forwarder was successfully created.' }
        format.json { render :show, status: :created, location: @forwarder }
      else
        format.html { render :new }
        format.json { render json: @forwarder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /forwarders/1
  # PATCH/PUT /forwarders/1.json
  def update
    respond_to do |format|
      if @forwarder.update(forwarder_params)
        format.html { redirect_to @forwarder, notice: 'Forwarder was successfully updated.' }
        format.json { render :show, status: :ok, location: @forwarder }
      else
        format.html { render :edit }
        format.json { render json: @forwarder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /forwarders/1
  # DELETE /forwarders/1.json
  def destroy
    @forwarder.destroy
    respond_to do |format|
      format.html { redirect_to forwarders_url, notice: 'Forwarder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_forwarder
      @forwarder = Forwarder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def forwarder_params
      params.require(:forwarder).permit(:name, :host, :group_id, :store_id, :kafka_broker_hosts, :zookeeper_hosts, :kafka_topics, :heartbeat_url)
    end
end
