class RemoveImageFromComponentTemplates < ActiveRecord::Migration[5.2]
  def up
    if ComponentTemplate.where.not(image: nil).empty?
      remove_column :component_templates, :image, :string
    else
      raise $!, "There is component that has image value"
    end
  end

  def down
    add_column :component_templates, :image, :string
  end
end
