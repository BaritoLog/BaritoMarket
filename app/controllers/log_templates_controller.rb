class LogTemplatesController < ApplicationController
  before_action :set_log_template, only: [:show, :edit, :update, :destroy]

  # GET /log_templates
  # GET /log_templates.json
  def index
    @log_templates = LogTemplate.all
  end

  # GET /log_templates/1
  # GET /log_templates/1.json
  def show
  end

  # GET /log_templates/new
  def new
    @log_template = LogTemplate.new
  end

  # GET /log_templates/1/edit
  def edit
  end

  # POST /log_templates
  # POST /log_templates.json
  def create
    @log_template = LogTemplate.new(log_template_params)

    respond_to do |format|
      if @log_template.save
        format.html { redirect_to @log_template, notice: 'Log template was successfully created.' }
        format.json { render :show, status: :created, location: @log_template }
      else
        format.html { render :new }
        format.json { render json: @log_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /log_templates/1
  # PATCH/PUT /log_templates/1.json
  def update
    respond_to do |format|
      if @log_template.update(log_template_params)
        format.html { redirect_to @log_template, notice: 'Log template was successfully updated.' }
        format.json { render :show, status: :ok, location: @log_template }
      else
        format.html { render :edit }
        format.json { render json: @log_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /log_templates/1
  # DELETE /log_templates/1.json
  def destroy
    @log_template.destroy
    respond_to do |format|
      format.html { redirect_to log_templates_url, notice: 'Log template was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_log_template
      @log_template = LogTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def log_template_params
      params.require(:log_template).permit(:name, :tps_limit, :zookeeper_instances, :kafka_instances, :es_instances, :consul_instances, :yggdrasil_instances, :kibana_instances)
    end
end
