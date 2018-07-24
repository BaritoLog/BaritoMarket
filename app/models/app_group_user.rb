class AppGroupUser < ApplicationRecord
  belongs_to :app_group
  belongs_to :role, class_name: 'AppGroupRole'
  belongs_to :user

  validates :app_group_id, uniqueness: { scope: [:user_id, :role_id] }
  validates :app_group_id, :user_id, :role_id, presence: true
end
