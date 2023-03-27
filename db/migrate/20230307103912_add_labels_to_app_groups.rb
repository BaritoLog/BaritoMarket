class AddLabelsToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :labels, :jsonb, default: {}
  end
end
