class AddLabelsToBaritoApp < ActiveRecord::Migration[5.2]
  def change
    add_column :barito_apps, :labels, :jsonb, default: {}
  end
end
