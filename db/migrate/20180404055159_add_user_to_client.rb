class AddUserToClient < ActiveRecord::Migration
  def change
    add_reference :clients, :user, index: true
  end
end
