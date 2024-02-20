class AddExpirationDateToGroupUser < ActiveRecord::Migration[5.2]
  def change
    add_column :group_users, :to_expire_on, :datetime
  end
end
