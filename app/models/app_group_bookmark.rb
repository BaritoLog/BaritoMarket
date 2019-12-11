class AppGroupBookmark < ApplicationRecord
  belongs_to :user
  belongs_to :app_group
end
