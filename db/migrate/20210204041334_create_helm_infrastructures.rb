class CreateHelmInfrastructures < ActiveRecord::Migration[5.2]
  def change
    create_table :helm_infrastructures do |t|
      t.belongs_to :app_group, foreign_key: true, null: false
      t.references :helm_cluster_template, foreign_key: true, null: false
      t.jsonb :override_values, null: false
      t.text :last_log

      t.timestamps
    end
  end
end
