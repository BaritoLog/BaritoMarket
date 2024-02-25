class RenameToExpireOnToExpirationDate < ActiveRecord::Migration[5.2]
  def change
    rename_column :group_users, :to_expire_on, :expiration_date
  end
end
