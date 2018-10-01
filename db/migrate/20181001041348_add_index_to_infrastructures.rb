class AddIndexToInfrastructures < ActiveRecord::Migration[5.2]
  def change
    add_index :infrastructures, :status
  end
end
