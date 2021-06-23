class AddInfrastructureFieldsToHelmInfrastructure < ActiveRecord::Migration[5.2]
  def change
    add_column :helm_infrastructures, :cluster_name, :string
    add_column :helm_infrastructures, :status, :string
    add_column :helm_infrastructures, :provisioning_status, :string
    add_column :helm_infrastructures, :max_tps, :integer

    reversible do |direction|
      direction.up do
        HelmInfrastructure.connection.schema_cache.clear!
        HelmInfrastructure.reset_column_information

        Infrastructure.all.each do |infra|
          helm_infra = infra.app_group.helm_infrastructure
          helm_infra.update!(
            cluster_name: infra.cluster_name,
            status: infra.status,
            provisioning_status: infra.provisioning_status,
            max_tps: infra.options['max_tps'].to_i,
          ) unless helm_infra.nil?
        end
      end
    end
  end
end
