class AddRedactStatusToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :redact_status, :string, default: 'INACTIVE'
  end
end
