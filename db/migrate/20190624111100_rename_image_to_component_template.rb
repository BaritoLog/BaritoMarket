class RenameImageToComponentTemplate < ActiveRecord::Migration[5.2]
  def change
    rename_column :component_templates, :image, :alias
  end
end
