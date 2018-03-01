class AddDatabagIdToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :databag_id, :integer
  end
end
