class AddReceiverPortToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :receiver_port, :string
  end
end
