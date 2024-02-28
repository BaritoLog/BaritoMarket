class AddExpirationDateToGroupUser < ActiveRecord::Migration[5.2]
  def change
    add_column :group_users, :expiration_date, :datetime
  end
end
