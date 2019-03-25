class ClusterTemplatesController < ApplicationController
  before_action :set_cluster_template, only: %i(show destroy update edit)

  def index
    authorize ClusterTemplate
    @cluster_templates = ClusterTemplate.all
  end

  def new
    authorize ClusterTemplate
    @cluster_template = ClusterTemplate.new
  end

  def edit
    authorize @cluster_template
    @instances = JSON.pretty_generate(@cluster_template.instances)
    @kafka_options = JSON.pretty_generate(@cluster_template.kafka_options)
  end

  def show
    authorize @cluster_template
    @instances = JSON.pretty_generate(@cluster_template.instances)
    @kafka_options = JSON.pretty_generate(@cluster_template.kafka_options)
  end

  def create
    authorize ClusterTemplate
    attributes = cluster_template_params.clone
    attributes[:instances] = JSON.parse(attributes[:instances])
    attributes[:kafka_options] = JSON.parse(attributes[:kafka_options])
    @cluster_template = ClusterTemplate.new(attributes)

    if @cluster_template.save
      redirect_to cluster_templates_path
    else
      flash[:messages] = @cluster_template.errors.full_messages
      render :new
    end
  end

  def destroy
    authorize ClusterTemplate
    infrastructures = Infrastructure.where(cluster_template: @cluster_template)
    if infrastructures.empty?
    	@cluster_template.destroy
    else
      flash[:messages] = @cluster_template.errors.full_messages

    end
  	redirect_to cluster_templates_path
  end

  def update
    authorize @cluster_template
    attributes = cluster_template_params.clone
    attributes[:instances] = JSON.parse(attributes[:instances])
    attributes[:kafka_options] = JSON.parse(attributes[:kafka_options])
    @cluster_template.update_attributes(attributes)
    redirect_to cluster_template_path(@cluster_template)
  end

  private

  def cluster_template_params
    params.require(:cluster_template).permit(
      :env,
      :name,
      :max_tps,
      :instances,
      :kafka_options
    )
  end

  def set_cluster_template
    @cluster_template = ClusterTemplate.find(params[:id])
  end
end
