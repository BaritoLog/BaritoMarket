class CreateInfrastructureLocation < ActiveRecord::Migration[5.2]
  def change
    create_table :infrastructure_locations do |t|
      t.string :name, null: false
      t.string :destination_server, null: false
      t.string :kibana_address_format, null: false
      t.string :producer_address_format, null: false
      t.boolean :is_active

      t.timestamps
    end

    add_index :infrastructure_locations, :name, unique: true
  end
end
