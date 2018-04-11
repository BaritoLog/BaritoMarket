class CreateAppGroups < ActiveRecord::Migration
  def change
    create_table :app_groups do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
