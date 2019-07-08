class RemoveImageFromInfrastructureComponents < ActiveRecord::Migration[5.2]
  def up
    if InfrastructureComponent.where.not(image: nil).empty?
      remove_column :infrastructure_components, :image, :string
    else
      raise $!, "There is infrastructure component that has image value"
    end
  end

  def down
    add_column :infrastructure_components, :image, :string
  end
end
