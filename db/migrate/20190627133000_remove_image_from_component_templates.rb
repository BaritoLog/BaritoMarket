class RemoveImageFromComponentTemplates < ActiveRecord::Migration[5.2]
  def change
    remove_column :component_templates, :image, :string
  end
end
