class RemoveImageFromInfrastructureComponents < ActiveRecord::Migration[5.2]
  def change
    remove_column :infrastructure_components, :image, :string
  end
end
