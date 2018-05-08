class DropTableLogTemplates < ActiveRecord::Migration
  def change
    drop_table :log_templates
  end
end
