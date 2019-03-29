class CreateClusterTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :cluster_templates do |t|
      t.string :name
      t.jsonb :instances
      t.jsonb :options
      t.timestamps null: false
    end
    add_index :cluster_templates, :name
  end
end