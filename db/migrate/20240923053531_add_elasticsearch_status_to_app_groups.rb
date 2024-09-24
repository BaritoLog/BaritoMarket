class AddElasticsearchStatusToAppGroups < ActiveRecord::Migration[5.2]
    def change
      add_column :app_groups, :elasticsearch_status, :string, default: 'INACTIVE'
    end
  end