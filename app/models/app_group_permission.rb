class AppGroupPermission < ApplicationRecord
  belongs_to :app_group
  belongs_to :group

  validates :app_group_id, uniqueness: { scope: :group_id }
end
