class AddIsMtlsEnabledToInfrastructureLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructure_locations, :is_mtls_enabled, :boolean
  end
end
