class AddDefaultToExpirationDate < ActiveRecord::Migration[5.2]
  def change
    change_column_default :group_users, :expiration_date, nil
  end
end
