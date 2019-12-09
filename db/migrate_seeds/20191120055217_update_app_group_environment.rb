class UpdateAppGroupEnvironment < ActiveRecord::Migration[5.2]
  def up
    app_groups.each do |app_group|
      app_group_name = app_group.name.downcase
      if app_group_name.include?('staging') || app_group_name.include?('integration') ||
          app_group_name.include?('small')
        app_group.environment = AppGroup.environments[:staging]
      end
    end
  end

  def down
    app_groups.each do |app_group|
      app_group.environment = AppGroup.environments[:production]
    end
  end

  private

  def app_groups
    AppGroup.all
  end
end
