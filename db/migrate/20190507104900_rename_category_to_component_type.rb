class RenameCategoryToComponentType < ActiveRecord::Migration[5.2]
  def change
    rename_column :infrastructure_components, :category, :component_type
  end
end