class AddUseK8sKibanaToHelmInfrastructure < ActiveRecord::Migration[5.2]
  def change
    add_column :helm_infrastructures, :use_k8s_kibana, :boolean, null: false, default: false
  end
end
