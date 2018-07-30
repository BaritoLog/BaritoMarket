class CreateInfrastructureComponents < ActiveRecord::Migration[5.2]
  def change
    create_table :infrastructure_components do |t|
      t.string      :hostname
      t.string      :category
      t.integer     :sequence
      t.text        :message
      t.string      :status
      t.string      :ipaddress
      t.references  :infrastructure
      t.timestamps  null: false
    end
  end
end
