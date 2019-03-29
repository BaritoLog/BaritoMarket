class AddInstancesToInfrastructures < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructures, :instances, :jsonb, null: false, default: {}
  end
end
