class AddImageToInfrastructureComponents < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructure_components, :image, :string
  end
end
