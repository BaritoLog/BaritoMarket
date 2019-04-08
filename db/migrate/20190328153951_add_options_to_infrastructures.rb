class AddOptionsToInfrastructures < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructures, :options, :jsonb, null: false, default: {}
  end
end
