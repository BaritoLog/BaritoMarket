class RenameTableServiceToClient < ActiveRecord::Migration
  def change
    rename_table :services, :clients
  end
end
