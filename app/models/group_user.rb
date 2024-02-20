class GroupUser < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  belongs_to :role, class_name: 'AppGroupRole'

  validates :group_id, :user_id, :role_id, :to_expire_on, presence: true
  validates :group_id, uniqueness: { scope: :user_id }
end
