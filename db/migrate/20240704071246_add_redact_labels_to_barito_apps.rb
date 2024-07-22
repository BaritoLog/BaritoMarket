class AddRedactLabelsToBaritoApps < ActiveRecord::Migration[5.2]
  def change
    add_column :barito_apps, :redact_labels, :jsonb, default: {}
  end
end
