class AppGroup < ApplicationRecord
  validates :name, presence: true

  has_many :barito_apps
  has_many :app_group_users
  has_many :users, through: :app_group_users
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

  def increase_log_count(new_count)
    update_column(:log_count, log_count + new_count.to_i)
  end
end
