class AppGroup < ApplicationRecord
  validates :name, presence: true

  belongs_to :user
  has_many :barito_apps
  has_many :app_group_admins
  has_many :admins, through: :app_group_admins, source: :user
  has_many :app_group_permissions
  has_many :groups, through: :app_group_permissions
  has_one :infrastructure

  def self.setup(env, params)
    ActiveRecord::Base.transaction do
      app_group = AppGroup.create(name: params[:name], user_id: params[:user_id])
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
