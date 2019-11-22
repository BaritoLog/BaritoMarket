class AppGroupTeam < ApplicationRecord
  belongs_to :app_group
  belongs_to :role, class_name: 'AppGroupRole'
  belongs_to :group

  validates :app_group_id, uniqueness: { scope: :group_id }
  validates :app_group_id, presence: true
end
