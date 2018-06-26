class AppGroup < ApplicationRecord
  validates :name, presence: true
  has_many :barito_apps
  has_one :infrastructure

  def self.setup(env, params)
    ActiveRecord::Base.transaction do
      app_group = AppGroup.create(name: params[:name])
      infrastructure = Infrastructure.setup(
        env,
        name: params[:name], 
        capacity: params[:capacity], 
        app_group_id: app_group.id,
      )

      [app_group, infrastructure]
    end
  end
end
