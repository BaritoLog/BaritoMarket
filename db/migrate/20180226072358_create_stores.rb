class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name
      t.string :elasticsearch_host
      t.string :kibana_host

      t.timestamps null: false
    end
  end
end
