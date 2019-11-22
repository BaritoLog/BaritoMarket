class AppGroupTeam < ApplicationRecord
  belongs_to :app_group
  belongs_to :role, class_name: 'AppGroupRole'
  belongs_to :group

  validates :app_group, uniqueness: { scope: :group }
  validates :app_group, :role, presence: true
end
