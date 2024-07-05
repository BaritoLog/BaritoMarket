class AddRedactLabelsToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :redact_labels, :jsonb, default: {}
  end
end
