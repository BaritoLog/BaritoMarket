class GroupUser < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  belongs_to :role, class_name: 'AppGroupRole'

  validates :group_id, :user_id, :role_id, :expiration_date, presence: true
  validates :group_id, uniqueness: { scope: :user_id }
end
