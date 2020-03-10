class RemoveImageFromComponentTemplates < ActiveRecord::Migration[5.2]
  def up
    remove_column :component_templates, :image, :string
  end

  def down
    add_column :component_templates, :image, :string
  end
end
