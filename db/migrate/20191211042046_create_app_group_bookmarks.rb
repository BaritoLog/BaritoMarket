class CreateAppGroupBookmarks < ActiveRecord::Migration[5.2]
  def change
    create_table :app_group_bookmarks do |t|
      t.references :user, foreign_key: true, index: true, null: false
      t.references :app_group, foreign_key: true, index: true, null: false

      t.timestamps
    end
  end
end
