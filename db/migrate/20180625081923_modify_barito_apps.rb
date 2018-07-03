class ModifyBaritoApps < ActiveRecord::Migration[5.2]
  def up
    ActiveRecord::Base.transaction do
      remove_column :barito_apps, :app_group
      add_reference :barito_apps, :app_group, index: true
      add_column :barito_apps, :topic_name, :string
      add_column :barito_apps, :max_tps, :integer
      rename_column :barito_apps, :app_status, :status

      BaritoApp.all.each do |barito_app|
        app_group = AppGroup.create!(name: barito_app.name)
        infrastructure = Infrastructure.create!(
          name: barito_app.name,
          cluster_name: barito_app.cluster_name,
          capacity: barito_app.tps_config,
          provisioning_status: barito_app.setup_status,
          status: barito_app.status,
          consul_host: barito_app.consul_host,
          app_group: app_group
        )

        max_tps = TPS_CONFIG[infrastructure.capacity]['max_tps']
        barito_app.update!(
          app_group_id: app_group.id,
          topic_name: barito_app.name.parameterize.underscore,
          max_tps: max_tps
        )
      end

      remove_column :barito_apps, :tps_config
      remove_column :barito_apps, :cluster_name
      remove_column :barito_apps, :setup_status
      remove_column :barito_apps, :consul_host
    end
  end
end
