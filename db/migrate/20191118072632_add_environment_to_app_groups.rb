class AddEnvironmentToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :environment, :string, default: 'PRODUCTION'
  end
end
