class CreateComponentTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :component_templates do |t|
      t.string :env
      t.string :name
      t.string :max_tps
      t.jsonb :instances
      t.jsonb :kafka_options
      t.timestamps null: false
    end
  end
end