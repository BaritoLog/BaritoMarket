class AddIsActiveToHelmInfrastructure < ActiveRecord::Migration[5.2]
  def change
    add_column :helm_infrastructures, :is_active, :boolean, null: false, default: false
  end
end
