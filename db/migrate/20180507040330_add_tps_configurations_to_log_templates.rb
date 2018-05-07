class AddTpsConfigurationsToLogTemplates < ActiveRecord::Migration
  def change
    add_column :log_templates, :consul_instances, :integer, :default => 0
    add_column :log_templates, :yggdrasil_instances, :integer, :default => 0
    add_column :log_templates, :kibana_instances, :integer, :default => 0
  end
end
