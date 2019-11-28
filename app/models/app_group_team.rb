class AppGroupTeam < ApplicationRecord
  belongs_to :app_group
  belongs_to :group

  validates :app_group, uniqueness: { scope: :group }
  validates :app_group, :group, presence: true
end
