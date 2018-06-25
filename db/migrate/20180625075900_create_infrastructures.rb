class CreateInfrastructures < ActiveRecord::Migration[5.2]
  def change
    create_table :infrastructures do |t|
      t.string :name
      t.string :cluster_name
      t.string :capacity
      t.string :provisioning_status
      t.string :status
      t.string :consul_host
      t.references :app_group
      t.timestamps null: false
    end
  end
end
