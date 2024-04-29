class AddExpirationDateToAppGroupUser < ActiveRecord::Migration[5.2]
  def change
    add_column :app_group_users, :expiration_date, :datetime
  end
end
