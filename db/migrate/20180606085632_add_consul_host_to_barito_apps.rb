class AddConsulHostToBaritoApps < ActiveRecord::Migration[5.2]
  def change
    add_column :barito_apps, :consul_host, :string
  end
end
