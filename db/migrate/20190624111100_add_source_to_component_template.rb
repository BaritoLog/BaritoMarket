class AddSourceToComponentTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :component_templates, :source, :jsonb
    rename_column :component_templates, :component_attributes, :bootstrappers
    remove_column :component_templates, :image, :string
  end
end
