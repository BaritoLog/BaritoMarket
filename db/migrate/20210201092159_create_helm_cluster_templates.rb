class CreateHelmClusterTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :helm_cluster_templates do |t|
      t.string :name, null: false
      t.jsonb :values, null: false
      t.integer :max_tps, null: false

      t.timestamps
    end
  end
end
