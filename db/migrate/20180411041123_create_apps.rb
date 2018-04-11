class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name
      t.integer :log_template_id
      t.integer :app_group_id

      t.timestamps null: false
    end
  end
end
