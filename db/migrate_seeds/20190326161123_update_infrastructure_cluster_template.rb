class UpdateInfrastructureClusterTemplate < ActiveRecord::Migration[5.2]
  def up
    all_infrastructures = Infrastructure.all

    all_infrastructures.each do |infra|
      next unless infra.cluster_template.nil?
      infra_name = infra.name.downcase
      if infra_name.include?("staging") || infra_name.include?("integration")
        update_attrs(infra, "Staging", infra.capacity)
      elsif infra_name.include?("production")
        update_attrs(infra, "Production", infra.capacity)
      else
        update_attrs(infra, "Production", infra.capacity)
      end
    end

    public
      def update_attrs(infra, env, capacity)
        cluster_template_name = "Log - " + capacity.capitalize
        ct = ClusterTemplate.find_by(name: cluster_template_name)

        infra.update(
          cluster_template: ct, 
          capacity: ct.name,
          instances: ct.instances,
          options: ct.options
        )
      end
  end

  def down
    all_infrastructures = Infrastructure.all
    all_infrastructures.each do |infra|
      capacity = infra.capacity
      infra.update(
        cluster_template: nil, 
        capacity: capacity.downcase,
        instances: {},
        options: {},
      )
    end
  end
end
