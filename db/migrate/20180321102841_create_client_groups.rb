class CreateClientGroups < ActiveRecord::Migration
  def change
    create_table :client_groups do |t|
      t.belongs_to :client, index: true
      t.belongs_to :user_group, index: true

      t.timestamps null: false
    end
  end
end
