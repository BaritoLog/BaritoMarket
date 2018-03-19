class AddApplicationSecretToClient < ActiveRecord::Migration
  def change
    add_column :clients, :application_secret, :string
  end
end
