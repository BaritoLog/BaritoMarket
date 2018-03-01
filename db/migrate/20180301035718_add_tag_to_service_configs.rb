class AddTagToServiceConfigs < ActiveRecord::Migration
  def change
    add_column :service_configs, :tags, :string, default: false, null: false unless column_exists? :service_configs, :tags
  end
end
