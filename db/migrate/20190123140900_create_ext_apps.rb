# frozen_string_literal: true

class CreateExtApps < ActiveRecord::Migration[5.2]
  def change
    create_table :ext_apps do |t|
      t.string :name,                         null: false
      t.text :description

      t.string :hashed_access_token,          null: false
      t.datetime :access_token_generated_at,  null: false

      t.bigint :created_by_id
      t.timestamps null: false
    end

    add_foreign_key :ext_apps, :users, column: :created_by_id
    add_index :ext_apps, :name, unique: true
    add_index :ext_apps, :created_by_id
    add_index :ext_apps, :hashed_access_token
  end
end
