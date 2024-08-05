class AddInfrastructureLocationToHelmInfrastructure < ActiveRecord::Migration[5.2]
  def change
    add_reference :helm_infrastructures, :infrastructure_location, foreign_key: true
  end
end
