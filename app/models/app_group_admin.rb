class AppGroupAdmin < ActiveRecord::Base
  belongs_to :app_group
  belongs_to :user

  validates :app_group_id, uniqueness: { scope: :user_id }
end
