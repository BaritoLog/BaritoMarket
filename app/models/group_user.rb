class GroupUser < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates :group_id, :user_id, presence: true
  validates :group_id, uniqueness: { scope: :user_id }
end
