class AddKibanaAndProducerHelmInfrastructureRefsToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_reference :app_groups, :kibana_helm_infrastructure, foreign_key: { to_table: :helm_infrastructures }
    add_reference :app_groups, :producer_helm_infrastructure, foreign_key: { to_table: :helm_infrastructures }
  end
end
