class AddForwarderToServices < ActiveRecord::Migration
  def change
    add_column :services, :forwarder_id, :integer, default: false, null: false unless column_exists? :services, :forwarder_id
  end
end
