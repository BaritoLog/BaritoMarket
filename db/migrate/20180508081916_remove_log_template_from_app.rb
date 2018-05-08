class RemoveLogTemplateFromApp < ActiveRecord::Migration
  def change
    remove_column :apps, :log_template_id
    add_column :apps, :tps_config_id, :string
  end
end
