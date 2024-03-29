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
    @manifests = JSON.pretty_generate(@cluster_template.manifests)
    @options = JSON.pretty_generate(@cluster_template.options)
  end

  def show
    authorize @cluster_template
    @manifests = JSON.pretty_generate(@cluster_template.manifests)
    @options = JSON.pretty_generate(@cluster_template.options)
  end

  def create
    authorize ClusterTemplate
    attributes = cluster_template_params.clone
    attributes[:manifests] = JSON.parse(attributes[:manifests])
    attributes[:options] = JSON.parse(attributes[:options])
    @cluster_template = ClusterTemplate.new(attributes)

    if @cluster_template.save
      audit_log :create_cluster_template, { "cluster_template_name" => @cluster_template.name }
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
      audit_log :delete_cluster_template, { "cluster_template_name" => @cluster_template.name }
    	@cluster_template.destroy
    else
      flash[:messages] = @cluster_template.errors.full_messages

    end
  	redirect_to cluster_templates_path
  end

  def update
    authorize @cluster_template
    from_attributes = @cluster_template.attributes
    attributes = cluster_template_params.clone
    attributes[:manifests] = JSON.parse(attributes[:manifests])
    attributes[:options] = JSON.parse(attributes[:options])
    @cluster_template.update_attributes(attributes)

    audit_log :update_cluster_template, { "from_attributes" => from_attributes, "to_attributes" => @cluster_template.attributes }
    redirect_to cluster_template_path(@cluster_template)
  end

  private

  def cluster_template_params
    params.require(:cluster_template).permit(
      :name,
      :manifests,
      :options
    )
  end

  def set_cluster_template
    @cluster_template = ClusterTemplate.find(params[:id])
  end
end
