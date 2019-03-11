class CreateComponentProperties < ActiveRecord::Migration[5.2]
  def change
    create_table :component_properties do |t|
      t.string :name
      t.jsonb :component_attributes
      t.timestamps null: false
    end
  end
end